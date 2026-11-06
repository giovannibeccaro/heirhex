# Piano autonomo: tappe 0, 1, 2

Questo piano si esegue **senza Giovanni presente**. Le specifiche sono nei documenti di design (percorso in `CLAUDE.md`). Questo file dice **cosa fare, in che ordine e quando un compito è finito**.

## Regole di autonomia (valgono per tutto il piano)
1. **Ramo di lavoro:** prima di tutto crea e usa il ramo `autonomo/tappe-0-2`. Non lavorare mai su `main`.
2. **Un compito = un commit**, solo con i test verdi. Messaggio: `[T1.3] mattoncini: danno e blocco` (id del compito + descrizione).
3. **Push del ramo** su `origin` dopo ogni tappa completata (copia di sicurezza). Mai `--force`, mai su `main`.
4. **Non chiedere: annota.** Se emerge un dubbio di design, scegli l'opzione **più prudente e più facile da cambiare**, scrivila nel diario (`docs/DIARIO.md`, sezione "Scelte prese da solo") e vai avanti. Non modificare i documenti di design.
5. **Diario:** aggiorna `docs/DIARIO.md` alla fine di ogni compito (cosa è fatto, file toccati, scelte, domande per Giovanni).
6. **Quando fermarsi:**
   - un test che non riesci a far passare dopo 3 tentativi diversi → annota il problema, salta il compito se gli altri non ne dipendono, altrimenti fermati;
   - un dubbio di design che blocca più compiti → fermati e scrivi la domanda;
   - qualsiasi operazione fuori dal repository, o che richiede di scaricare più di qualche MB (es. i modelli di esportazione di Godot) → non farla, annotala.
7. **Ripartenza:** se la sessione si interrompe, alla ripresa leggi il diario e riparti dal primo compito non completato.
8. Comando Godot: `godot` se è nel PATH, altrimenti `/Applications/Godot.app/Contents/MacOS/Godot`.

---

## Tappa 0 — Preparazione
| Id | Compito | Finito quando |
| --- | --- | --- |
| T0.1 | Struttura delle cartelle di `CLAUDE.md` (`core/`, `ui/`, `data/generati/`, `data/manuali/`, `testi/`, `strumenti/`, `test/`, `docs/`), con un README breve in ognuna | Cartelle presenti, Godot apre il progetto senza errori |
| T0.2 | Installa **GUT** in `addons/gut` (versione compatibile con Godot 4.7) e un test di esempio | Un comando da terminale esegue i test senza grafica (`--headless`) e passa. Il comando è scritto in `docs/COMANDI.md` |
| T0.3 | `testi/testi.csv` (colonne `keys,it,en`) con 2-3 chiavi di esempio, importato come traduzione | Un test verifica che `tr("chiave")` restituisce il testo italiano |
| T0.4 | Preset di esportazione Web in `export_presets.cfg` | Preset presente. **Non** scaricare i modelli di esportazione: annota nel diario che vanno installati da Godot |

## Tappa 1 — Motore di combattimento (`core/`, solo classi pure + test)
Specifiche: `02-design/combattimento.md`, `02-design/bilanciamento.md`, `02-design/nemici-prototipo.md`, `06-prototipo/schemi-dati.md`. Per i test usa dati minimi in `test/fixtures/` (non dipendere ancora dall'esportazione della tappa 2).

| Id | Compito | Finito quando |
| --- | --- | --- |
| T1.1 | **Stato:** combattente (vita, vita massima, blocco, stati), culla, stato del combattimento (mazzo, mano, scarti, esilio, energia, turno), generatore casuale **con seme** (stesso seme = stessa partita) | Test su creazione dello stato e determinismo del seme |
| T1.2 | **Ciclo del turno:** inizio turno (blocco **dimezzato**, con la quota come parametro configurabile perché "da provare"), 3 energia, pesca fino alla mano dell'età, fine turno con scarto della mano, rimescolamento degli scarti quando il mazzo finisce, turno dei nemici | Test su un ciclo di più turni |
| T1.3 | **Mattoncini** (schemi-dati.md, sezione Effetto): danno (bersagli, percentuale, ignora blocco), blocco (se, culla, a scelta: la scelta è un parametro dell'azione del giocatore), cura, pesca, energia, applica stato, rimuovi stato, aggiungi carta, scarta, esilia, annulla intenzione, riprendi dagli scarti, ruba carta, evoca | Un test per mattoncino, compresi i casi limite (blocco che assorbe tutto, bersaglio morto, mazzo vuoto) |
| T1.4 | **Stati:** Fattura (soglia 7, 30% della vita massima, persistente), Paura, Malocchio, Radici (D28, regole della Fattura) | Test per ogni stato, compresa la soglia della Fattura |
| T1.5 | **Modificatori:** sistema unico, ordine fisso somma → moltiplica → imposta, durate (turno, combattimento, vita, stirpe) | Test sull'ordine di calcolo e sulle durate |
| T1.6 | **Agganci agli eventi di gioco** (inizio e fine turno, carta giocata, inizio e fine combattimento) usati da stati e modificatori | Test che uno stato reagisce al suo aggancio |
| T1.7 | **Nemici:** intenzioni con comportamento pesato (peso, massimo di fila, ricarica) e a sequenza, forme della fattura (moltiplicatori), fasi del Tiranno sotto il 50%, ultimo rintocco al turno 8 (letale, ignora il blocco, non annullabile) | Test per ogni comportamento |
| T1.8 | **Esito e registro:** vittoria, sconfitta, e un registro di tutte le azioni del combattimento (servirà al debug e agli snapshot) | Test di un combattimento breve completo, con registro leggibile |

| T1.9 | **Identificatori centralizzati:** sposta le stringhe interne (bersagli, tipi di effetto, stati, agganci) in `enum` o costanti `StringName` definite una sola volta; i `match` usano le costanti. Vedi la convenzione in `CLAUDE.md` | Nessun identificatore interno scritto a mano fuori dal file dedicato; test verdi |

## Tappa 2 — Dati
Specifiche: `06-prototipo/schemi-dati.md`, foglio `06-prototipo/bilanciamento.xlsx` (nella cartella di design; leggerlo, mai modificarlo).

| Id | Compito | Finito quando |
| --- | --- | --- |
| T2.1 | `strumenti/esporta.py`: legge il foglio (valori calcolati, `openpyxl` con `data_only=True`) e scrive `data/generati/carte.json`, `nemici.json`, `bilanciamento.json` con campo `schema` | Lo script gira e produce JSON validi. Istruzioni in `docs/COMANDI.md` |
| T2.2 | **Caricatore dei dati** in `core/`, con controllo della versione di schema; converte le stringhe dei JSON negli identificatori di T1.9 e rifiuta valori sconosciuti | Test che carica i JSON generati e test che un valore sconosciuto viene segnalato |
| T2.3 | **Validatore** (riferimenti a id esistenti, chiavi di testo presenti in `testi.csv`, versioni di schema): script e test | Il validatore passa sui dati attuali; le chiavi di testo mancanti vengono aggiunte a `testi.csv` con il nome provvisorio italiano dal foglio |
| T2.4 | **Simulazione:** script headless che gioca 1000 combattimenti con il mazzo base delle Masciare contro ciascun nemico normale, con una strategia semplice (gioca le carte che fanno più danni, difende se l'intenzione è un attacco). Misura turni medi e vita persa | Rapporto in `docs/report-simulazione.md`, confrontato con le ancore (3 turni, 10-15% di vita persa). Non correggere i numeri: solo riportare |

## Alla fine
- Diario aggiornato con un **riassunto per Giovanni**: cosa funziona, scelte prese da solo, domande aperte, cosa serve da lui.
- Push del ramo. **Non** fare merge su `main`: lo decide Giovanni dopo la revisione.

---

## Tappa 2b — Correzioni dopo la revisione (2026-11-06)
Leggi prima `docs/RISPOSTE.md`: contiene le risposte di Giovanni alle domande del diario e le nuove decisioni (D57-D61). Lavora sul ramo **`autonomo/correzioni-revisione`**, creato a partire da `autonomo/tappe-0-2`.

| Id | Compito | Finito quando |
| --- | --- | --- |
| T2.5 | **La culla diventa la casa** (D59): rinomina in codice, dati manuali, testi e test (`culla` → `casa`, `se_o_culla` → `se_o_casa`, `attacco_culla` → `attacco_casa`, `predatore_culla` → `predatore_casa`). La casa è attiva **in tutte le età**: niente più logica "culla inattiva in giovinezza". Stesse regole: vita 35, a 0 tratto negativo all'erede e torna a metà | Nessun riferimento a "culla" rimasto (codice, dati, testi, test); test verdi |
| T1.9 | **Identificatori centralizzati** (vedi `CLAUDE.md`), se non già fatto: bersagli, tipi di effetto, stati, agganci in `enum` o costanti `StringName` definite una volta; il caricatore converte e rifiuta valori sconosciuti | Nessun identificatore interno scritto a mano fuori dal file dedicato; test verdi |
| T2.6 | **Riesporta dal foglio** (nuove ancore: efficienza 0,6, danno dei nemici +25%, G = 3, divorata × 1,5 in Forme fattura cella D6, *Ricordo* con `esilia`) e implementa il potenziamento della forma divorata (× 1,5 sui valori dell'intenzione indicata, oltre ai moltiplicatori globali). Validatore a zero errori | JSON rigenerati, validatore verde, test sulla forma divorata |
| T2.7 | **Rifai la simulazione** e aggiorna `docs/report-simulazione.md` con una tabella **prima / dopo** (turni medi, vita persa, casa persa) e le osservazioni. Obiettivo indicativo per le Masciare: circa 4 turni, 10-15% di vita persa. Non correggere i numeri: solo misurare | Report aggiornato con il confronto |

Alla fine: diario aggiornato con riassunto e domande, push del ramo, nessun merge.
