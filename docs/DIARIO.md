# Diario di lavoro

Aggiornato dall'agente alla fine di ogni compito. Ordine: dal più recente al più vecchio.

## Riassunto per Giovanni
(da compilare alla fine del piano o quando l'agente si ferma)

## Domande per Giovanni
(nessuna per ora)

## Scelte prese da solo
- **Godot non è in `/Applications`**: l'eseguibile usato è `/Users/giovannibeccaro/Downloads/Godot.app/Contents/MacOS/Godot` (4.7.2). Conviene spostarlo in `/Applications` (i comandi in `docs/COMANDI.md` usano una variabile `GODOT`, facile da cambiare).
- **Python degli strumenti in un ambiente locale** (`strumenti/.venv`, ignorato da git): il Python di Homebrew non permette `pip install --user` (PEP 668). Dentro c'è solo `openpyxl`.
- **Commit della configurazione iniziale**: `CLAUDE.md`, `project.godot`, `.claude/settings.json`, `.editorconfig`, `.gitattributes`, l'icona e la `.gitignore` modificata erano non tracciati; li ho inclusi nel commit di T0.1.

## Registro dei compiti

### T0.2 — GUT ✅
- GUT **9.7.1** (prima versione con le correzioni per Godot 4.7) copiato in `addons/gut`, plugin attivato in `project.godot`.
- `.gutconfig.json`: test in `res://test/` e sottocartelle, prefisso `test_`.
- `strumenti/test.sh`: importa le risorse ed esegue i test headless; uscita 1 se un test fallisce (verificato con un test rosso temporaneo).
- `test/test_esempio.gd` passa. Comandi spiegati in `docs/COMANDI.md`.
- Nota Godot: dalla 4.4 ogni script ha un file `.uid` accanto (identificatore stabile della risorsa): vanno committati.

### T0.1 — Struttura delle cartelle ✅
- Create `core/`, `ui/`, `data/generati/`, `data/manuali/`, `testi/`, `strumenti/`, `test/`, `docs/`, ognuna con un README breve.
- `.gitignore`: aggiunti `strumenti/.venv/` e `__pycache__/`.
- Verifica: `Godot --headless --path . --import` apre il progetto senza errori.
