# Comandi

Tutti i comandi si lanciano dalla cartella del progetto (`~/Progetti/heirhex`).

## Godot
Gli script cercano Godot in quest'ordine: variabile `GODOT`, `godot` nel PATH, `/Applications/Godot.app/...`, `~/Downloads/Godot.app/...`.
Per usarne uno diverso: `GODOT=/percorso/Godot strumenti/test.sh`.

## Test (GUT, senza grafica)
```sh
strumenti/test.sh
```
Esegue tutti i file `test/**/test_*.gd`. Uscita `0` = tutti verdi, `1` = almeno un test rosso.
Prima importa le risorse (`--import`), così i file generati da Godot (es. le traduzioni da `testi.csv`) sono aggiornati.

Un solo file di test:
```sh
strumenti/test.sh -gselect=test_esempio.gd
```

Cosa fa dietro le quinte:
```sh
godot --headless --path . -s res://addons/gut/gut_cmdln.gd
```
- `--headless`: nessuna finestra, nessuna grafica (serve anche per le simulazioni).
- `-s`: esegue uno script al posto della scena principale; `gut_cmdln.gd` è il lanciatore di GUT da terminale.
- La configurazione (cartella `test/`, prefisso `test_`, sottocartelle) sta in `.gutconfig.json`.

I test si possono lanciare anche dall'editor: pannello **GUT** in basso (il plugin è attivo in Progetto → Impostazioni → Plugin).

## Esportazione Web (playtest nel browser)
Prerequisito, **una volta sola**: installare i modelli di esportazione di Godot 4.7.2 (circa 1 GB, non inclusi nel repository).
In Godot: **Editor → Gestisci modelli di esportazione → Scarica e installa**.

Poi:
```sh
mkdir -p build/web
godot --headless --path . --export-release "Web" build/web/index.html
```
Il preset "Web" sta in `export_presets.cfg`: senza thread (`variant/thread_support=false`), così il gioco gira su qualsiasi hosting statico (es. itch.io) senza intestazioni speciali; escluse dall'esportazione le cartelle `test/`, `addons/gut/`, `strumenti/`, `docs/`.
La cartella `build/` è ignorata da git.

Per provarla in locale serve un piccolo server (il browser non apre i file `.wasm` da `file://`):
```sh
python3 -m http.server -d build/web 8000
```
e aprire http://localhost:8000.

## Esportazione dei dati dal foglio di calcolo
Prerequisito, **una volta sola**: un ambiente Python locale con `openpyxl` (il Python di Homebrew non permette `pip install` globale).
```sh
python3 -m venv strumenti/.venv
strumenti/.venv/bin/pip install -r strumenti/requirements.txt
```
Poi, ogni volta che il foglio cambia:
```sh
strumenti/.venv/bin/python strumenti/esporta.py
```
Legge `06-prototipo/bilanciamento.xlsx` nella cartella di design (solo lettura, valori calcolati) e scrive in `data/generati/`:
`carte.json`, `nemici.json`, `bilanciamento.json` (ancore, età, casa, testamento, invecchiamento, economia, forme della fattura, mazzi base) e `testi_provvisori.csv` (nomi italiani dal foglio, usati dal validatore).
Per un altro foglio o un'altra cartella: `strumenti/esporta.py percorso.xlsx cartella_uscita`.

Nota: `data_only=True` legge i valori **salvati** nel file. Se il foglio è stato modificato con un programma che non ricalcola le formule al salvataggio, i valori potrebbero essere vecchi: aprire e salvare il foglio con Excel, Numbers o Google Fogli prima di esportare.

## Validatore dei dati
```sh
strumenti/valida.sh              # controlla e basta
strumenti/valida.sh --correggi   # aggiunge a testi.csv le chiavi mancanti
```
Controlla: versioni di schema, riferimenti a id esistenti (stati, carte, nemici, intenzioni delle sequenze, mazzi base), tipi di effetto e bersagli noti, eventi e filtri dei modificatori, chiavi di testo presenti in `testi/testi.csv`. Le carte fuori budget sono **avvisi**, non errori. Uscita `0` = nessun errore.
Con `--correggi` le chiavi mancanti vengono aggiunte con il nome italiano provvisorio del foglio (`data/generati/testi_provvisori.csv`) e la colonna inglese vuota, da tradurre.
Ordine consigliato dopo aver cambiato il foglio: `esporta.py` → `valida.sh --correggi` → `test.sh`.
La logica sta in `core/dati/validatore.gd` (`Validatore`), così il gioco potrà eseguirla anche all'avvio in modalità debug.

## Simulazione di bilanciamento
```sh
godot --headless --path . -s res://strumenti/simula.gd -- --combattimenti 1000 --casata masciare --turni-obiettivo 4
```
`--turni-obiettivo` è la durata con cui confrontare i risultati: senza, si usa l'ancora del foglio (3, mazzo medio); per le Masciare l'obiettivo è circa 4 (D58).
Gioca i combattimenti con il mazzo base della casata contro ogni nemico normale (giovinezza ed età adulta, più una variante di riferimento che attacca soltanto) con la strategia semplice di `core/simulazione/giocatore_automatico.gd`, e riscrive `docs/report-simulazione.md` (la sezione Osservazioni va poi riscritta a mano). C'è anche uno scenario con tutti i nemici in forma divorata (tre età, due strategie) che misura il colpo dell'intenzione potenziata. Circa un minuto con 1000 combattimenti.
