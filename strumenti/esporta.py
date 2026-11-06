#!/usr/bin/env python3
"""Esporta il foglio di calcolo del bilanciamento nei JSON del gioco.

Legge i valori calcolati (openpyxl, data_only=True) e scrive in data/generati/:
  carte.json, nemici.json, bilanciamento.json, testi_provvisori.csv

Lo script conosce i *tipi* (mattoncini, colonne, livelli), mai i contenuti.
Il foglio non si modifica mai: si legge soltanto.

Uso:
  strumenti/.venv/bin/python strumenti/esporta.py [percorso.xlsx] [cartella_uscita]
"""

import csv
import json
import re
import sys
import unicodedata
from pathlib import Path

import openpyxl

SCHEMA = 1

RADICE = Path(__file__).resolve().parent.parent
FOGLIO_PREDEFINITO = Path(
    "/Users/giovannibeccaro/Library/CloudStorage/GoogleDrive-gio.beccaro@gmail.com/"
    "Il mio Drive/Traducila/Game Dev/06-prototipo/bilanciamento.xlsx"
)
USCITA_PREDEFINITA = RADICE / "data" / "generati"

# Campo del JSON in cui va la colonna "parametro", per tipo di effetto.
PARAMETRO_PER_TIPO = {
    "applica_stato": "stato",
    "rimuovi_stato": "stato",
    "aggiungi_carta": "carta",
    "evoca": "nemico",
    "ruba_carta": "da",
}
# Valori della colonna parametro tradotti (ruba_carta: dalla_mano -> mano).
PARAMETRO_VALORI = {"dalla_mano": "mano", "dal_mazzo": "mazzo"}

# Momenti del Lascito; se la colonna non contiene un momento, è un bersaglio
# e l'effetto vale una volta a inizio vita.
MOMENTI_LASCITO = {"inizio_vita", "inizio_combattimento"}

# I Tiranni cambiano comportamento sotto questa quota di vita (nemici-prototipo.md).
# Le intenzioni della seconda fase (le carte rubate) le genera il gioco.
TIRANNO_SOGLIA_FASE = 0.5

# Chiavi stabili per le ancore usate dal motore (etichetta nel foglio -> chiave).
# Le altre ancore ricevono una chiave ricavata dall'etichetta.
ANCORE_NOTE = {
    "U — danno di una carta comune da 1 energia": "u",
    "Energia per turno": "energia_per_turno",
    "Valore per turno del giocatore": "valore_per_turno",
    "Efficienza (quota del turno che diventa danno)": "efficienza",
    "Turni desiderati: combattimento normale": "turni_normale",
    "Turni desiderati: élite": "turni_elite",
    "Turni desiderati: Tiranno": "turni_tiranno",
    "Vita persa obiettivo, combattimento normale (min)": "vita_persa_min",
    "Vita persa obiettivo, combattimento normale (max)": "vita_persa_max",
    "Danno per turno di un nemico normale (in U)": "danno_nemico_normale_u",
    "Bonus di budget: carte base": "bonus_budget_base",
    "Bonus di budget: carte comuni": "bonus_budget_comune",
    "Bonus di budget: carte rare": "bonus_budget_rara",
    "Bonus di budget: carte neutre": "bonus_budget_neutra",
    "Bonus di budget: carte uniche": "bonus_budget_unica",
    "Tolleranza dello scostamento": "tolleranza_scostamento",
    "Radici: valore aggiunto per carica": "radici_per_carica",
    "Fattura: soglia (cariche)": "fattura_soglia",
    "Fattura: danno quando si compie (% vita max)": "fattura_danno_quota",
    "Valore della Devozione (energia per combattimento)": "devozione_energia",
    "Generazioni per abbattere il Tiranno": "generazioni_tiranno",
    "Turno dell'ultimo rintocco del Tiranno": "turno_ultimo_rintocco",
}

ALTRE_CHIAVI = {
    "Carte che invecchiano a ogni generazione (le più giocate)": "carte_che_invecchiano",
    'Evoluzione "Più forte": aumento dei valori in punti': "piu_forte_aumento",
    'Evoluzione "Tradizione": valore obiettivo (energia)': "tradizione_valore_energia",
    "G — grani di una Notte normale (unità dell'economia)": "g",
}


class ErroreFoglio(Exception):
    pass


# --- utilità -------------------------------------------------------------------

def numero(v):
    """Numeri interi come int, gli altri come float arrotondati; stringhe vuote -> None."""
    if v is None or v == "" or v == "–":
        return None
    if isinstance(v, bool):
        return v
    if isinstance(v, (int, float)):
        if float(v).is_integer():
            return int(v)
        return round(float(v), 6)
    try:
        return numero(float(str(v).replace(",", ".")))
    except ValueError:
        return None


def testo(v):
    return "" if v is None else str(v).strip()


def chiave_da_etichetta(etichetta):
    s = unicodedata.normalize("NFKD", etichetta).encode("ascii", "ignore").decode()
    s = re.sub(r"[^a-zA-Z0-9]+", "_", s.lower()).strip("_")
    return s


def righe(foglio, intestazione=1):
    """Righe del foglio come dizionari {colonna: valore}, saltando quelle senza la prima colonna."""
    titoli = [testo(c.value) for c in foglio[intestazione]]
    for riga in foglio.iter_rows(min_row=intestazione + 1, values_only=True):
        if riga[0] is None or testo(riga[0]) == "":
            continue
        yield {titoli[i]: riga[i] for i in range(min(len(titoli), len(riga))) if titoli[i]}


def effetto(tipo, bersaglio, parametro, valore, dove):
    """Costruisce un mattoncino dalle colonne del foglio."""
    tipo = testo(tipo)
    e = {"tipo": tipo}
    v = numero(valore)
    param = testo(parametro)
    if param == "letale":
        e["letale"] = True
        e["ignora_blocco"] = True
    elif param:
        campo = PARAMETRO_PER_TIPO.get(tipo)
        if campo is None:
            raise ErroreFoglio(f"{dove}: parametro '{param}' non previsto per il tipo '{tipo}'")
        e[campo] = PARAMETRO_VALORI.get(param, param)
    if v is not None and not e.get("letale"):
        e["valore"] = v
    if testo(bersaglio):
        e["bersaglio"] = testo(bersaglio)
    return e


# --- schede --------------------------------------------------------------------

def leggi_mazzi_base(wb):
    mazzi = {}
    for r in righe(wb["Mazzi base"]):
        casata, carta, copie = testo(r.get("Casata")), testo(r.get("Carta (id)")), numero(r.get("Copie"))
        if not carta or copie is None:
            continue  # righe di totale o note
        mazzi.setdefault(casata, []).append({"carta": carta, "copie": copie})
    return mazzi


def leggi_carte(wb, mazzi_base, nomi):
    personali = {voce["carta"] for mazzo in mazzi_base.values() for voce in mazzo}
    carte = []
    for r in righe(wb["Carte"]):
        cid = testo(r["id"])
        dove = f"Carte/{cid}"
        carta = {
            "id": cid,
            "nome": f"carta.{cid}.nome",
            "tipo": testo(r["Tipo"]),
            "rarita": testo(r["Rarità"]),
            "casata": testo(r["Casata"]),
        }
        if testo(r.get("Famiglia")):
            carta["famiglia"] = testo(r["Famiglia"])
        carta["costo"] = numero(r["Costo"]) or 0
        effetti = []
        for n in (1, 2, 3):
            if testo(r.get(f"Eff.{n} tipo")):
                effetti.append(effetto(r[f"Eff.{n} tipo"], r.get(f"Eff.{n} bersaglio"), r.get(f"Eff.{n} parametro"),
                                       r.get(f"Eff.{n} valore"), f"{dove}/Eff.{n}"))
        carta["effetti"] = effetti
        if cid in personali:
            carta["personale"] = True
        elif carta["rarita"] == "base":
            # Rarità base ma fuori dai mazzi base: carta di sistema (Dispetto, Ricordo…)
            carta["di_sistema"] = True
        if testo(r.get("Lascito tipo")):
            colonna = testo(r.get("Lascito bersaglio / momento"))
            momento = colonna if colonna in MOMENTI_LASCITO else "inizio_vita"
            bersaglio = "se" if colonna in MOMENTI_LASCITO else colonna
            carta["lascito"] = {
                "momento": momento,
                "effetti": [effetto(r["Lascito tipo"], bersaglio, r.get("Lascito parametro"),
                                    r.get("Lascito valore"), f"{dove}/Lascito")],
            }
        carta["invecchiamento"] = "sistemico"
        budget = {
            "valore_totale": numero(r.get("Valore totale (energia)")),
            "valore_atteso": numero(r.get("Valore atteso")),
            "scostamento": numero(r.get("Scostamento")),
            "esito": testo(r.get("Esito")),
        }
        carta["budget"] = {k: v for k, v in budget.items() if v not in (None, "")}
        carte.append(carta)
        nomi[carta["nome"]] = testo(r.get("Nome (it, provvisorio)"))
    return carte


def leggi_intenzioni(wb):
    """Intenzioni raggruppate per nemico, nell'ordine del foglio."""
    per_nemico = {}
    for r in righe(wb["Intenzioni"]):
        nid, iid = testo(r["Nemico (id)"]), testo(r["Intenzione (id)"])
        dove = f"Intenzioni/{nid}/{iid}"
        elenco = per_nemico.setdefault(nid, [])
        intenzione = next((i for i in elenco if i["id"] == iid), None)
        if intenzione is None:
            intenzione = {"id": iid, "tipo": testo(r["Tipo"]), "effetti": [], "_peso": testo(r.get("Peso"))}
            for campo, colonna in (("max_di_fila", "Max di fila"), ("ricarica", "Ricarica (turni)")):
                v = numero(r.get(colonna))
                if v is not None:
                    intenzione[campo] = v
            elenco.append(intenzione)
        e = effetto(r["Effetto"], r.get("Bersaglio"), r.get("Parametro"), r.get("Valore base"), dove)
        if e.get("letale"):
            intenzione["non_annullabile"] = True
        intenzione["effetti"].append(e)
    return per_nemico


def leggi_nemici(wb, nomi):
    intenzioni = leggi_intenzioni(wb)
    nemici = []
    for r in righe(wb["Nemici"]):
        nid = testo(r["id"])
        nemico = {
            "id": nid,
            "nome": f"nemico.{nid}.nome",
            "ruolo": testo(r["Ruolo"]),
            "livello": testo(r["Livello"]),
            "vita": numero(r["Vita base"]),
            "turni_desiderati": numero(r.get("Turni desiderati")),
        }
        proprie = intenzioni.pop(nid, [])
        sequenza = []
        for i in proprie:
            peso = i.pop("_peso")
            m_seq = re.fullmatch(r"seq\s+(\d+)(?:\s*-\s*(\d+))?", peso)
            m_turno = re.fullmatch(r"turno\s+(\d+)", peso)
            if m_seq:
                da, a = int(m_seq.group(1)), int(m_seq.group(2) or m_seq.group(1))
                sequenza.extend((pos, i["id"]) for pos in range(da, a + 1))
            elif m_turno:
                i["turno"] = int(m_turno.group(1))
            elif numero(peso) is not None:
                i["peso"] = numero(peso)
            elif peso:
                raise ErroreFoglio(f"Intenzioni/{nid}/{i['id']}: peso '{peso}' non riconosciuto")
        if sequenza:
            nemico["comportamento"] = "sequenza"
            nemico["sequenza"] = [iid for _, iid in sorted(sequenza)]
        else:
            nemico["comportamento"] = "pesato"
        nemico["intenzioni"] = proprie
        if nemico["livello"] == "tiranno":
            nemico["fasi"] = [{"sotto_quota_vita": TIRANNO_SOGLIA_FASE, "comportamento": "pesato", "intenzioni": []}]
        nemici.append(nemico)
        nomi[nemico["nome"]] = testo(r.get("Nome (it, provvisorio)"))
    if intenzioni:
        raise ErroreFoglio(f"Intenzioni di nemici inesistenti: {sorted(intenzioni)}")
    return nemici


def leggi_bilanciamento(wb, mazzi_base):
    b = {}
    ancore = {}
    for riga in wb["Ancore"].iter_rows(min_row=2, values_only=True):
        if riga[0] is None:
            continue
        etichetta = testo(riga[0])
        ancore[ANCORE_NOTE.get(etichetta, chiave_da_etichetta(etichetta))] = numero(riga[1])
    b["ancore"] = ancore

    b["combattimento"] = {"energia_per_turno": ancore.get("energia_per_turno")}

    budget = {}
    for r in righe(wb["Budget"]):
        budget[testo(r["Effetto (tipo)"])] = {"energia_per_unita": numero(r.get("Energia per unità"))}
    moltiplicatori = {}
    for riga in wb["Budget"].iter_rows(min_row=2, min_col=8, max_col=9, values_only=True):
        if riga[0]:
            moltiplicatori[testo(riga[0])] = numero(riga[1])
    b["budget"] = {"effetti": budget, "bersagli": moltiplicatori}

    eta = {}
    culla = None
    perdite = {}
    for riga in wb["Età"].iter_rows(min_row=2, values_only=True):
        nome = testo(riga[0])
        if nome in ("infanzia", "giovinezza", "eta_adulta", "vecchiaia"):
            if nome not in eta:  # la seconda tabella (danno della Fattura) si ricalcola: si salta
                eta[nome] = {"vita": numero(riga[1]), "mano": numero(riga[2]),
                             "energia": numero(riga[3]), "tappe": numero(riga[4])}
        elif nome == "culla":
            culla = numero(riga[1])
        if isinstance(riga[3], str) and chiave_da_etichetta(riga[3]) and numero(riga[4]) is not None:
            perdite[chiave_da_etichetta(riga[3])] = numero(riga[4])
    b["eta"] = eta
    b["culla"] = {"vita": culla}
    b["testamento"] = {"quota_perdite": perdite}

    inv = wb["Invecchiamento"]
    livelli = []
    altri = {}
    for riga in inv.iter_rows(min_row=2, values_only=True):
        if isinstance(riga[0], (int, float)):
            livelli.append({"livello": int(riga[0]), "etichetta": testo(riga[1]),
                            "evoluzioni": numero(riga[2]), "tramandabile": testo(riga[3]) == "sì"})
        elif testo(riga[0]) and numero(riga[3]) is not None:
            etichetta = testo(riga[0])
            altri[ALTRE_CHIAVI.get(etichetta, chiave_da_etichetta(etichetta))] = numero(riga[3])
    b["invecchiamento"] = {"livelli": livelli, **altri}

    economia = {}
    for r in righe(wb["Economia"]):
        valore = numero(r.get("Grani"))
        if valore is not None:
            economia[ALTRE_CHIAVI.get(testo(r["Voce"]), chiave_da_etichetta(testo(r["Voce"])))] = valore
    b["economia"] = economia

    forme = {}
    for r in righe(wb["Forme fattura"]):
        forme[testo(r["Forma"])] = {"dalla_generazione": numero(r["Dalla generazione"]),
                                    "vita": numero(r["Moltiplicatore vita"]),
                                    "danno": numero(r["Moltiplicatore danno"])}
    b["forme"] = forme
    b["mazzi_base"] = mazzi_base
    return b


# --- principale ----------------------------------------------------------------

def scrivi_json(percorso, contenuto):
    with open(percorso, "w", encoding="utf-8") as f:
        json.dump(contenuto, f, ensure_ascii=False, indent=2)
        f.write("\n")


def esporta(foglio, uscita):
    wb = openpyxl.load_workbook(foglio, data_only=True, read_only=False)
    nomi = {}
    mazzi_base = leggi_mazzi_base(wb)
    carte = leggi_carte(wb, mazzi_base, nomi)
    nemici = leggi_nemici(wb, nomi)
    bilanciamento = leggi_bilanciamento(wb, mazzi_base)

    uscita.mkdir(parents=True, exist_ok=True)
    origine = {"schema": SCHEMA, "generato_da": foglio.name}
    scrivi_json(uscita / "carte.json", {**origine, "carte": carte})
    scrivi_json(uscita / "nemici.json", {**origine, "nemici": nemici})
    scrivi_json(uscita / "bilanciamento.json", {**origine, **bilanciamento})
    # Nomi provvisori italiani: il validatore li usa per le chiavi mancanti in testi.csv
    with open(uscita / "testi_provvisori.csv", "w", encoding="utf-8", newline="") as f:
        w = csv.writer(f, lineterminator="\n")
        w.writerow(["keys", "it"])
        for chiave in sorted(nomi):
            w.writerow([chiave, nomi[chiave]])
    return len(carte), len(nemici)


def main(argv):
    foglio = Path(argv[1]) if len(argv) > 1 else FOGLIO_PREDEFINITO
    uscita = Path(argv[2]) if len(argv) > 2 else USCITA_PREDEFINITA
    if not foglio.exists():
        print(f"Foglio non trovato: {foglio}", file=sys.stderr)
        return 2
    try:
        n_carte, n_nemici = esporta(foglio, uscita)
    except ErroreFoglio as e:
        print(f"Errore nel foglio: {e}", file=sys.stderr)
        return 1
    print(f"Esportati {n_carte} carte e {n_nemici} nemici in {uscita}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
