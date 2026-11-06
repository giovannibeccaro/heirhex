# Diario di lavoro

Aggiornato dall'agente alla fine di ogni compito. Ordine: dal più recente al più vecchio.

## Riassunto per Giovanni
(da compilare alla fine del piano o quando l'agente si ferma)

## Domande per Giovanni
1. **Furto della Janara Madre "dalla mano"**: la mano si scarta a fine turno, quindi nel turno dei nemici è vuota. Per ora la Janara Madre ruba una carta a caso **tra quelle della mano appena scartata** (`ruba_carta` con `da: mano`). Alternative: rubare dal mazzo, oppure rubare all'inizio del tuo turno dopo la pesca. Quale preferisci?

## Scelte prese da solo
- **Godot non è in `/Applications`**: l'eseguibile usato è `/Users/giovannibeccaro/Downloads/Godot.app/Contents/MacOS/Godot` (4.7.2). Conviene spostarlo in `/Applications` (i comandi in `docs/COMANDI.md` usano una variabile `GODOT`, facile da cambiare).
- **Python degli strumenti in un ambiente locale** (`strumenti/.venv`, ignorato da git): il Python di Homebrew non permette `pip install --user` (PEP 668). Dentro c'è solo `openpyxl`.
- **Intestazione di `testi.csv`: `keys,it,en`** (come nel piano), non `chiave,it,en` come in `CLAUDE.md`: `keys` è la convenzione di Godot. La prima colonna in realtà può chiamarsi in qualsiasi modo; se preferisci `chiave` basta rinominarla.
- **Testi inglesi provvisori**: dove manca una traduzione ne metto una provvisoria (es. Fattura → "Hex"), da rivedere.
- **Blocco ridotto per difetto**: 7 dimezzato fa 3 (arrotondamento per difetto). Il blocco dei nemici si riduce all'inizio del *loro* turno, come per il giocatore.
- **Limite della mano: 10 carte** (`RegoleCombattimento.mano_limite`): il design non lo fissa; oltre il limite le carte restano nel mazzo.
- **Culla inattiva** (giovinezza): gli effetti che la bersagliano non fanno nulla e il blocco "a te o alla culla" va a te. Presumo che i nemici che puntano alla culla compaiano solo dall'età adulta (`eta_comparsa`).
- **Culla a 0**: torna a metà della vita massima arrotondata (35 → 18). Se torna a 0 nello stesso combattimento torna di nuovo a metà, senza un secondo tratto.
- **Bersaglio "nemico" non scelto**: il motore usa il primo nemico vivo; una scelta che punta a un nemico morto rende la carta non giocabile (la carta resta in mano, nessun costo).
- **Ordine dei compiti**: T1.5 (modificatori) e T1.6 (agganci) prima di T1.4 (stati), perché Radici e Paura sono modificatori e Malocchio e Fattura reagiscono ad agganci. Un commit per compito resta.
- **Più modificatori "imposta"** sulla stessa proprietà: vale l'ultimo aggiunto.
- **Durata "turno"**: scade alla fine del turno del giocatore.
- **Effetti a fine combattimento**: quando il combattimento è finito i mattoncini non si eseguono più; l'evento `fine_combattimento` serve agli ascoltatori esterni (la vita, le ricompense), non a effetti di carte o stati.
- **Paura**: all'inizio del tuo turno (dopo la pesca) la carta giocabile più costosa in mano costa +1 fino alla fine del turno; a parità di costo tocca la prima in mano. Una carica = un turno. Se il costo si ricalcolasse dopo ogni carta giocata, la Paura renderebbe +1 ogni carta del turno: troppo forte.
- **Fattura oltre la soglia**: se le cariche superano 7 (es. 5 + 4), si compie una volta e le cariche in eccesso si perdono (il dato dice "rimuovi tutte").
- **Commit della configurazione iniziale**: `CLAUDE.md`, `project.godot`, `.claude/settings.json`, `.editorconfig`, `.gitattributes`, l'icona e la `.gitignore` modificata erano non tracciati; li ho inclusi nel commit di T0.1.

## Registro dei compiti

### T1.4 — Stati ✅
- `data/manuali/stati.json`: **Fattura** (soglia 7, 30% della vita massima ignorando il blocco, si azzera, `persistente`), **Paura** (durata), **Malocchio** (durata: a inizio turno scarta una carta a caso), **Radici** (intensità: +2 per carica a danno, blocco e cura delle carte ereditate). Nessuna regola specifica nel codice: tutto è dato.
- Nuovo mattoncino `applica_modificatore` (serviva alla Paura: nessuna combinazione degli altri bastava). Bersaglio `carta_piu_costosa_in_mano` oppure un combattente.
- Testi di nomi e descrizioni degli stati in `testi.csv`.
- Test: `test/stati/test_stati.gd` (16 test, compresa la soglia della Fattura, l'eccesso di cariche, la Fattura ereditata dalla vita, la Paura a parità di costo).

### T1.6 — Agganci agli eventi di gioco ✅
- `core/eventi/eventi_gioco.gd` (`EventiGioco`): eventi `inizio_combattimento`, `fine_combattimento`, `inizio_turno`, `fine_turno`, `carta_giocata`, `soglia_raggiunta`; `ascolta(evento, funzione)` per chi vuole agganciarsi da fuori (interfaccia, vita, future meccaniche).
- `Combattimento.emetti()` è il punto unico: reagiscono gli stati, scadono i modificatori a tempo (`turno` alla fine del turno del giocatore, `combattimento` alla fine), partono gli agganci esterni (`impostazioni.agganci`, per Lascito, amuleti, presenze), poi gli ascoltatori.
- `core/stati/gestore_stati.gd` (`GestoreStati`): regole generiche degli stati (intensità, durata che cala a fine turno di chi lo porta, soglia), agganci degli stati e modificatori degli stati (anche `per_carica`, e bersaglio `se` = chi porta lo stato).
- `inizio_turno` del giocatore scatta **dopo** la pesca (così il Malocchio trova carte da scartare).
- Test: `test/eventi/test_agganci.gd` (11 test) con stati di prova in `test/fixtures/stati.json`.

### T1.5 — Modificatori ✅ (fatto prima di T1.4: Radici e Paura ne hanno bisogno)
- `core/modificatori/modificatore.gd` (`Modificatore`) e `sistema_modificatori.gd` (`SistemaModificatori`): un'unica forma `{fonte, bersaglio {tipo, filtro}, proprieta, operazione, valore, durata}`; ordine fisso somma → moltiplica → imposta; durate ordinate (la fine del combattimento toglie anche quelli del turno; restano `vita` e `stirpe`).
- Filtri supportati: carte (`ereditata`, `uid`, `id`, `tag`, `rarita`, `tipo`, `famiglia`, `casata`), nemici (`uid`, `id`, `ruolo`, `livello`). Un filtro sconosciuto non corrisponde mai.
- Nel combattimento: `costo` (minimo 0), `valore_effetti` (solo danno, blocco, cura), `danno_subito`, `energia`, `mano`. I modificatori passano in `impostazioni.modificatori`.
- Test: `test/modificatori/test_modificatori.gd` (17 test).

### T1.3 — Mattoncini ✅
- `core/effetti/mattoncini.gd`: danno (nemico, tutti, casuale, `percentuale`, `ignora_blocco`), blocco (se, culla, `se_o_culla` scelto con `scelte.se_o_culla`), cura, pesca, energia, applica_stato, rimuovi_stato (numero o `"tutte"`), aggiungi_carta (`dove`: mazzo/mano/scarti), scarta (`modo`: scelta/casuale), esilia (`bersaglio`: se = la carta giocata, mano = carte scelte), annulla_intenzione (rispetta `non_annullabile`), riprendi_dagli_scarti, ruba_carta (`da`: mano/mazzo), evoca (`nemico`, limite di nemici in campo).
- Le scelte del giocatore arrivano in `gioca_carta(uid, scelte)`: `nemico` (uid), `se_o_culla`, `scarta`/`esilia`/`riprendi` (liste di uid). Senza scelta il motore usa un valore predefinito (primo nemico vivo, "se", prime carte, ultima scartata).
- Test: `test/effetti/test_mattoncini.gd` (46 test, compresi blocco che assorbe tutto, bersaglio morto, mazzo e scarti vuoti, limite della mano, culla a 0).
- `strumenti/test.sh` ora fallisce anche se uno script ha un errore di sintassi: GUT da solo saltava il file e diceva "tutti verdi".
- Nota Godot: il progetto tratta come errore l'avviso "tipo dedotto da un Variant" (`var x := array.back()`); in quei casi serve il tipo esplicito (`var x: Carta = ...`).

### T1.2 — Ciclo del turno ✅
- `Combattimento`: `inizia()`, `gioca_carta(uid, scelte)`, `termina_turno()`, `finito()`. Inizio turno: blocco ridotto (quota in `RegoleCombattimento.quota_blocco_mantenuta`, 0,5 = dimezzato, 0 = svanisce), 3 energia (non si accumula), pesca fino alla mano dell'età. Fine turno: scarto della mano, turno dei nemici (ognuno riduce il proprio blocco, esegue l'intenzione mostrata), poi i nemici rivelano la successiva.
- Rimescolamento degli scarti quando il mazzo finisce; limite di carte in mano (10, configurabile).
- Culla a 0: un tratto negativo (massimo uno per combattimento) e torna a metà.
- `Mattoncini` (danno e blocco per ora) con funzioni statiche; `IntelligenzaNemici` (sequenza per ora); `Registro` di base.
- Test: `test/combattimento/test_turno.gd` (15 test, tra cui un ciclo di 6 turni che conserva le carte).
- Nota Godot: due `RefCounted` che si tengono a vicenda non vengono mai liberati (Godot conta i riferimenti, non ha un garbage collector). Per questo i mattoncini ricevono il combattimento come parametro invece di tenerlo in una variabile.

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
