class_name Simulatore
extends RefCounted
## Gioca molti combattimenti in uno scenario e raccoglie le misure (per report e taratura).
## Non cambia nessun dato: lavora sul catalogo che riceve.


## Mazzo di riferimento di una fase (D65) come voci per le impostazioni del combattimento.
## Le carte con livello ≥ 1 contano come ereditate (sono per forza passate di generazione).
static func mazzo_riferimento(catalogo: Catalogo, fase: String) -> Array:
	var mazzo := []
	for voce in catalogo.bilanciamento["mazzi_riferimento"][fase]["carte"]:
		for i in int(voce["copie"]):
			mazzo.append({"id": voce["carta"], "livello": int(voce["livello"]), "ereditata": int(voce["livello"]) > 0})
	return mazzo


static func fase_della_forma(catalogo: Catalogo, forma: StringName) -> String:
	return str(catalogo.bilanciamento["forme"][forma]["mazzo_riferimento"])


## Obiettivi della forma. Un obiettivo di turni con minimo = massimo (es. "4") diventa ±0,5:
## una media non è mai esattamente un numero intero.
const TOLLERANZA_TURNI := 0.5


static func obiettivi(catalogo: Catalogo, forma: StringName) -> Dictionary:
	var o: Dictionary = catalogo.bilanciamento["forme"][forma]["obiettivi"].duplicate()
	if is_equal_approx(float(o["turni_min"]), float(o["turni_max"])):
		o["turni_min"] = float(o["turni_min"]) - TOLLERANZA_TURNI
		o["turni_max"] = float(o["turni_max"]) + TOLLERANZA_TURNI
	return o


## Gioca `quanti` combattimenti (semi da primo_seme) e restituisce le misure:
## vittorie, turni[], vita_persa[] (quota della vita massima), casa_persa[], tratti, fattura[],
## colpi_potenziati[] (danno subito dalle intenzioni potenziate), uccisi_dal_potenziato.
static func simula(catalogo: Catalogo, regole: RegoleCombattimento, mazzo: Array, nemico: String, eta: StringName,
		forma: StringName, strategia: GiocatoreAutomatico.Strategia, quanti: int, primo_seme: int = 1) -> Dictionary:
	var b := catalogo.bilanciamento
	var dati_eta: Dictionary = b["eta"][eta]
	var vita := int(dati_eta["vita"])
	var vita_casa := int(b["casa"]["vita"])
	var potenziate: Array = catalogo.nemici[nemico].get("forme", {}).get(forma, {}).get("intenzioni_potenziate", []) if forma == Id.DIVORATA else []
	var t := {"vittorie": 0, "turni": [], "vita_persa": [], "casa_persa": [], "tratti": 0, "fattura": [],
		"colpi_potenziati": [], "uccisi_dal_potenziato": 0, "quanti": quanti, "vita": vita}
	for seme in range(primo_seme, primo_seme + quanti):
		var c := Combattimento.new(catalogo, {
			"seme": seme, "mazzo": mazzo, "nemici": [{"id": nemico, "forma": forma}],
			"giocatore": {"vita": vita, "vita_max": vita},
			"casa": {"vita": vita_casa},
			"mano": int(dati_eta["mano"]),
		}, regole)
		GiocatoreAutomatico.gioca_combattimento(c, 50, strategia)
		var r := c.riepilogo()
		if r["esito"] == "vittoria":
			t["vittorie"] += 1
		t["turni"].append(r["turni"])
		t["vita_persa"].append(float(r["vita_persa"]) / float(r["vita_max"]))
		t["casa_persa"].append(vita_casa - int(r["casa_vita"]))
		t["tratti"] += int(r["tratti_negativi"])
		t["fattura"].append(int(r["stati_persistenti"].get("fattura", 0)))
		_colpi_potenziati(c, potenziate, t)
	return t


## Dal registro: danno subito dal giocatore a ogni esecuzione di un'intenzione potenziata,
## e se quel colpo ha chiuso il combattimento con la sconfitta.
static func _colpi_potenziati(c: Combattimento, potenziate: Array, t: Dictionary) -> void:
	if potenziate.is_empty():
		return
	var in_corso := false
	var subito := 0
	for v in c.registro.voci:
		if v["tipo"] == Id.R_INTENZIONE_ESEGUITA:
			if in_corso:
				t["colpi_potenziati"].append(subito)
			in_corso = potenziate.has(str(v.get("intenzione", "")))
			subito = 0
		elif in_corso and v["tipo"] == Id.DANNO and v.get("a") == Id.GIOCATORE:
			subito += int(v["subito"])
		elif in_corso and v["tipo"] == Id.FINE_COMBATTIMENTO and v.get("esito") == "sconfitta":
			t["uccisi_dal_potenziato"] += 1
		elif in_corso and (v["tipo"] == Id.R_INTENZIONE or v["tipo"] == Id.INIZIO_TURNO):
			t["colpi_potenziati"].append(subito)
			in_corso = false
	if in_corso:
		t["colpi_potenziati"].append(subito)


# --- statistiche ------------------------------------------------------------------

static func media(valori: Array) -> float:
	if valori.is_empty():
		return 0.0
	var somma := 0.0
	for v in valori:
		somma += float(v)
	return somma / valori.size()


static func percentile(valori: Array, p: float) -> float:
	if valori.is_empty():
		return 0.0
	var ordinati := valori.duplicate()
	ordinati.sort()
	return float(ordinati[clampi(int(p * (ordinati.size() - 1)), 0, ordinati.size() - 1)])


## Quanto un valore sta fuori dall'intervallo [minimo, massimo]: 0 dentro, negativo sotto, positivo sopra.
static func distanza(valore: float, minimo: float, massimo: float) -> float:
	if valore < minimo:
		return valore - minimo
	if valore > massimo:
		return valore - massimo
	return 0.0


# --- proposte di taratura (solo in memoria) ------------------------------------------

## Applica a un catalogo (in memoria, mai ai file) una proposta di numeri:
## { nemici: { id: { vita, intenzioni: { id_intenzione: { danno: valore } } } },
##   forme: { forma: { vita, danno, intenzione_potenziata } } }
## "danno" imposta il valore di tutti gli effetti di danno (non letali) dell'intenzione.
static func applica_proposta(catalogo: Catalogo, proposta: Dictionary) -> void:
	var nemici: Dictionary = proposta.get("nemici", {})
	for id in nemici:
		var n: Dictionary = catalogo.nemici[id]
		var p: Dictionary = nemici[id]
		if p.has("vita"):
			n["vita"] = int(p["vita"])
		var intenzioni: Dictionary = p.get("intenzioni", {})
		for id_intenzione in intenzioni:
			var intenzione := IntelligenzaNemici.cerca(n["intenzioni"], str(id_intenzione))
			assert(not intenzione.is_empty(), "Intenzione sconosciuta: %s/%s" % [id, id_intenzione])
			for e: Dictionary in intenzione["effetti"]:
				if StringName(e.get("tipo", "")) == Id.DANNO and not bool(e.get("letale", false)) and intenzioni[id_intenzione].has("danno"):
					e["valore"] = int(intenzioni[id_intenzione]["danno"])
	var forme: Dictionary = proposta.get("forme", {})
	for forma in forme:
		var f: Dictionary = catalogo.bilanciamento["forme"][forma]
		for campo in forme[forma]:
			f[campo] = forme[forma][campo]
