# Diario di lavoro

Aggiornato dall'agente alla fine di ogni compito. Ordine: dal più recente al più vecchio.

## Riassunto per Giovanni
(da compilare alla fine del piano o quando l'agente si ferma)

## Domande per Giovanni
(nessuna per ora)

## Scelte prese da solo
- **Godot non è in `/Applications`**: l'eseguibile usato è `/Users/giovannibeccaro/Downloads/Godot.app/Contents/MacOS/Godot` (4.7.2). Conviene spostarlo in `/Applications` (i comandi in `docs/COMANDI.md` usano una variabile `GODOT`, facile da cambiare).
- **Python degli strumenti in un ambiente locale** (`strumenti/.venv`, ignorato da git): il Python di Homebrew non permette `pip install --user` (PEP 668). Dentro c'è solo `openpyxl`.
- **Intestazione di `testi.csv`: `keys,it,en`** (come nel piano), non `chiave,it,en` come in `CLAUDE.md`: `keys` è la convenzione di Godot. La prima colonna in realtà può chiamarsi in qualsiasi modo; se preferisci `chiave` basta rinominarla.
- **Testi inglesi provvisori**: dove manca una traduzione ne metto una provvisoria (es. Fattura → "Hex"), da rivedere.
- **Commit della configurazione iniziale**: `CLAUDE.md`, `project.godot`, `.claude/settings.json`, `.editorconfig`, `.gitattributes`, l'icona e la `.gitignore` modificata erano non tracciati; li ho inclusi nel commit di T0.1.

## Registro dei compiti

### T1.1 — Stato del combattimento ✅
- `core/casuale.gd` (`Casuale`): generatore con seme, mescolamento Fisher-Yates, scelta pesata, stato salvabile (per snapshot).
- `core/combattimento/`: `Combattente` (vita, vita massima, blocco, stati), `Culla`, `Nemico`, `Carta` (copia di una carta con uid), `StatoCombattimento` (zone mazzo/mano/scarti/esilio/rubate, energia, turno), `RegoleCombattimento` (numeri configurabili), `Combattimento` (crea lo stato dalle impostazioni).
- `core/dati/catalogo.gd` (`Catalogo`): contenuti indicizzati per id; il motore chiede qui carte, nemici e stati.
- Test: `test/combattimento/test_stato.gd` (creazione, uid unici, vita parziale, stesso seme = stesso mazzo, ripristino del generatore). Dati minimi in `test/fixtures/`, con nomi di prova (colpo, riparo, fantoccio) per non dipendere dai contenuti veri.
- Spiegazione Godot: `class_name` registra la classe come tipo globale (si usa senza `preload`); `RefCounted` si libera da solo quando nessuno lo usa più, a differenza dei `Node`, che vivono nell'albero della scena.

### T0.4 — Preset di esportazione Web ✅
- `export_presets.cfg` con il preset "Web" (senza thread, uscita in `build/web/index.html`, esclusi test, GUT, strumenti, docs). `build/` in `.gitignore`.
- Verifica: `--export-release "Web"` riconosce il preset e si ferma solo per i **modelli di esportazione mancanti** (`web_nothreads_release.zip`). **Non li ho scaricati** (circa 1 GB): vanno installati da Godot, Editor → Gestisci modelli di esportazione. Istruzioni in `docs/COMANDI.md`.
- Il progetto non ha ancora una scena principale: l'esportazione avrà senso dalla tappa 3.

### T0.3 — Testi ✅
- `testi/testi.csv` con 3 chiavi di esempio; importato da Godot come traduzione (`testi.it.translation`, `testi.en.translation`), registrato in `project.godot` (Internazionalizzazione → Traduzioni), lingua di riserva `it`.
- I file `.translation` sono generati dall'importazione: aggiunti a `.gitignore` (`strumenti/test.sh` li rigenera con `--import`).
- `test/test_testi.gd`: `tr("stato.fattura.nome")` → "Fattura" in italiano, "Hex" in inglese; una chiave sconosciuta resta la chiave.
- Spiegazione Godot: il CSV non si legge a runtime; l'editor lo "importa" in risorse `Translation` binarie, una per lingua. `TranslationServer` sceglie quella della lingua attiva e `tr()` (metodo di ogni `Object`) fa la ricerca.

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
