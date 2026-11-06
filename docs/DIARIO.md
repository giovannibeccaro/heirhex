# Diario di lavoro

Aggiornato dall'agente alla fine di ogni compito. Ordine: dal più recente al più vecchio.

## Riassunto per Giovanni
(da compilare alla fine del piano o quando l'agente si ferma)

## Domande per Giovanni
4. **Grani: G = 18 nel foglio, G = 3 in D54.** La scheda Economia ha ancora i valori vecchi (carta comune 45, rara 70…), mentre il registro decisioni dice G = 3 (comune 8, rara 12, unica 18). Ho esportato il foglio così com'è: va aggiornato il foglio?
5. **Carte con effetti che il foglio non sa esprimere**: *Il nome del morto* (+4 danni per antenato) è esportata con soli 4 danni; *Ricordo di {antenato}* "si esilia dopo l'uso" è scritto solo nelle note. Per il secondo basterebbe aggiungere nel foglio un effetto `esilia` / `se` (come Pane e sale). Per il primo serve un mattoncino nuovo (contatore degli antenati) quando arriverà la stirpe.
2. **Lingua del codice**: hai chiesto perché è in italiano. Seguo la convenzione di `CLAUDE.md` (identificatori e commenti in italiano, come il design e i dati). Se preferisci l'inglese conviene deciderlo presto: ora il cambio costa poco.
3. **Forma "divorata"**: lo schema prevede `intenzioni_potenziate: ["morso"]` ma non dice di quanto. Per ora il motore gestisce solo i moltiplicatori globali di vita e danno e le `intenzioni_aggiunte` (cumulative: la divorata ha anche quelle della toccata). Come va potenziata un'intenzione?
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
- **Comportamento pesato senza scelte valide**: se `max_di_fila` e `ricarica` escludono tutto, si ignora prima la ricarica, poi anche il limite di fila (non succede con i dati attuali). Un'intenzione annullata conta comunque come scelta.
- **I JSON generati sono nel repository**: il gioco ne ha bisogno per funzionare e i cambi del foglio si vedono nei diff. Si rigenerano sempre con lo script, mai a mano.
- **Soglia della fase del Tiranno (50%)** scritta nello script di esportazione (`TIRANNO_SOGLIA_FASE`): non c'è nel foglio. Potrebbe diventare un'ancora.
- **Commit della configurazione iniziale**: `CLAUDE.md`, `project.godot`, `.claude/settings.json`, `.editorconfig`, `.gitattributes`, l'icona e la `.gitignore` modificata erano non tracciati; li ho inclusi nel commit di T0.1.

## Registro dei compiti

### T2.2 — Caricatore dei dati ✅
- `core/dati/caricatore.gd` (`Caricatore`): legge `data/generati/` (carte, nemici, bilanciamento) e `data/manuali/stati.json`, controlla il campo `schema` (supportato: 1), raccoglie gli errori in `errori` e restituisce `null` se ce n'è almeno uno. Rimette interi i numeri interi (il parser JSON di Godot li legge tutti come decimali).
- `RegoleCombattimento.da_bilanciamento()`: energia per turno dal foglio.
- Preset Web: `include_filter="*.json"` (Godot esporta solo le risorse che conosce; i JSON vanno inclusi a mano, altrimenti il gioco esportato non li trova).
- Test: `test/dati/test_caricatore.gd` (9 test: dati veri, mazzi base esistenti, un combattimento con i dati veri, schema non supportato o mancante, JSON rotto, file mancanti).

### T2.1 — Esportazione dal foglio ✅
- `strumenti/esporta.py` (Python, `openpyxl` con `data_only=True`; dipendenze in `strumenti/requirements.txt`). Scrive `data/generati/carte.json` (23 carte), `nemici.json` (5 nemici), `bilanciamento.json`, `testi_provvisori.csv`, tutti con `schema: 1`.
- Traduzioni dal foglio ai dati: colonna "parametro" nel campo giusto per tipo (`stato`, `carta`, `nemico`, `da`); `letale` → `letale` + `ignora_blocco` + intenzione `non_annullabile`; peso `seq 1-2` → `comportamento: sequenza` con l'elenco ordinato; `turno 8` → `turno: 8`; carte dei mazzi base → `personale: true`; rarità base fuori dai mazzi → `di_sistema: true`; Lascito: se la colonna è un momento vale a ogni combattimento, se è un bersaglio vale una volta a inizio vita; Tiranno → una seconda fase sotto il 50% con intenzioni vuote (le riempie il gioco con le carte rubate).
- Le colonne di controllo del budget finiscono in `budget` (il validatore le usa per gli avvisi).
- Verifica: lo script gira, i JSON si rileggono senza errori. Istruzioni in `docs/COMANDI.md`.

### T1.8 — Esito e registro ✅ (fine Tappa 1)
- `Combattimento.esito` (in corso, vittoria, sconfitta); dopo la fine nessuna azione ha effetto.
- `Combattimento.riepilogo()`: esito, turni, vita iniziale/finale/persa, stati persistenti (la Fattura passa alla vita), culla e tratti negativi, carte giocate per uid e per id (servirà all'obolo), carte rubate, vita dei nemici in quota (servirà al Tiranno tra le generazioni).
- `Registro.righe()` / `testo()`: una riga tecnica per azione, es. `[T1] danno da=lupo#1 a=giocatore valore=12 assorbito=7 subito=5 vita=95`. È un testo di debug, generico (nessun codice per tipo di voce), non di gioco.
- Test: `test/combattimento/test_esito.gd` (combattimento completo contro un lupo di prova, registro leggibile, stesso seme = stesso registro).
- Totale Tappa 1: 137 test verdi.

### T1.7 — Nemici ✅
- `core/nemici/intelligenza_nemici.gd`: comportamento `sequenza` (campo `sequenza` con gli id, anche ripetuti) e `pesato` (`peso`, `max_di_fila`, `ricarica`); intenzioni a turno fisso (`turno: N`); fasi (`fasi: [{ sotto_quota_vita, comportamento, intenzioni }]`, non tornano indietro); `conto_alla_rovescia()` per l'interfaccia.
- `Nemico`: intenzioni base, fasi, forma, memoria delle scelte.
- Forme della fattura: i moltiplicatori di vita e danno (da `bilanciamento.forme`) diventano modificatori del sistema unico (`vita_max` e `valore_effetti` sul nemico); le `intenzioni_aggiunte` delle forme si sommano.
- Ultimo rintocco: intenzione con `turno: 8`, `non_annullabile`, effetto `danno` con `letale: true` (toglie tutta la vita, ignora blocco e modificatori). Vale anche nella seconda fase.
- Le intenzioni generate dalle carte rubate arrivano da fuori (`impostazioni.nemici[i].intenzioni_fase`): la traduzione carta → intenzione è della tappa 5.
- Test: `test/nemici/test_nemici.gd` (14 test, tra cui 300 turni di comportamento pesato che rispettano i limiti).

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
