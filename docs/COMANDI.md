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
