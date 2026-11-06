# Diario di lavoro

Aggiornato dall'agente alla fine di ogni compito. Ordine: dal più recente al più vecchio.

## Riassunto per Giovanni
*Tappa 2c completata il 2026-11-06. Ramo `autonomo/risposte-2b` (creato da `autonomo/correzioni-revisione`), pushato su GitHub.*

**Merge su `main` non fatto**: me l'hai chiesto, ma `.claude/settings.json` vieta `git merge` (e il push su `main`), e non ho aggirato la regola. Per farlo tu (avanzamento rapido, senza conflitti; porta su `main` le tappe 0, 1, 2, 2b e 2c):
```sh
git switch main
git merge --ff-only autonomo/risposte-2b
git push origin main
```

**Cosa è cambiato (Tappa 2c)**
- **T2.8** (D62, D63): l'intenzione potenziata della forma divorata ora viene dalla colonna O del foglio; il motore non la indovina più. Ululato a 6. I valori divorati calcolati dal motore coincidono con la colonna J del foglio (test).
- **T2.9**: simulazione rifatta con il confronto con la Tappa 2b e uno scenario con la forma divorata. Risposta sul Morso della luna nel registro qui sotto.
- Piano aggiornato con la Tappa 2c e la nota D64 (Pantafica e Munaciello si misurano su una vita intera).
- 179 test verdi, validatore a 0 errori.

## Domande per Giovanni
### Tappa 2c (nuove)
1. **Morso della luna divorato**: non uccide a vita piena, ma contro il Lupenaro divorato chiude quasi ogni combattimento in vecchiaia con il mazzo base. Lo verifichiamo con un mazzo realistico di generazione 5 quando esisterà la stirpe, o vuoi già ora un limite (es. un colpo potenziato non supera una quota della vita massima)?

### Tappa 2b (risposte in `docs/RISPOSTE.md`, D62-D64: chiuse)
1. **Forma divorata**: va bene potenziare l'intenzione con più danno quando i dati non ne indicano una? In alternativa si aggiunge al foglio una colonna "potenziata in forma divorata" nella scheda Intenzioni (lo script la esporterebbe in `intenzioni_potenziate`).
2. **Lupenaro**: con il Morso della luna a 28 è di gran lunga il nemico più duro (16-21% di vita persa, 7-8 turni con la strategia prudente). È voluto, visto che insegna a leggere le intenzioni, o va avvicinato agli altri?
3. **Pantafica e Munaciello** tolgono poca vita diretta (0-10%): il loro costo sta in Fattura, Paura e Dispetto, che una simulazione di un solo combattimento non vede. Ti serve una misura diversa per loro (es. Fattura accumulata in una vita), da fare quando ci sarà la tappa della vita?
4. **Nomi dei campi**: in `Id` ho messo tutti i *valori* degli identificatori, non i *nomi dei campi* dello schema (`"valore"`, `"bersaglio"`…). Ti va bene così? (Vedi "Scelte prese da solo".)

### Tappe 0-2 (chiuse)
**Risposte del 2026-11-06 in `docs/RISPOSTE.md`.** Le domande qui sotto sono chiuse.

1. **Ancora dei 3 turni** (dalla simulazione): con il mazzo base i combattimenti durano 5-8 turni. L'ancora vale per il mazzo base o per un mazzo di metà vita? Se vale per il mazzo base, o la vita dei nemici (72) è troppo alta o il mazzo base ha troppa poca offesa (4 attacchi su 10 carte). Vedi `docs/report-simulazione.md`.
2. **Furto della Janara Madre "dalla mano"**: la mano si scarta a fine turno, quindi nel turno dei nemici è vuota. Per ora la Janara Madre ruba una carta a caso **tra quelle della mano appena scartata** (`ruba_carta` con `da: mano`). Alternative: rubare dal mazzo, oppure rubare all'inizio del tuo turno dopo la pesca. Quale preferisci?
3. **Grani: G = 18 nel foglio, G = 3 in D54.** La scheda Economia ha ancora i valori vecchi (carta comune 45, rara 70…), mentre il registro decisioni dice G = 3 (comune 8, rara 12, unica 18). Ho esportato il foglio così com'è: va aggiornato il foglio?
4. **Janara in giovinezza**: senza culla non fa danni. Va esclusa dalla giovinezza con `eta_comparsa`, oppure in giovinezza deve attaccare te?
5. **Forma "divorata"**: lo schema prevede `intenzioni_potenziate: ["morso"]` ma non dice di quanto. Per ora il motore gestisce solo i moltiplicatori globali di vita e danno e le `intenzioni_aggiunte` (cumulative: la divorata ha anche quelle della toccata). Come va potenziata un'intenzione?
6. **Carte con effetti che il foglio non sa esprimere**: *Il nome del morto* (+4 danni per antenato) è esportata con soli 4 danni; *Ricordo di {antenato}* "si esilia dopo l'uso" è scritto solo nelle note. Per il secondo basterebbe aggiungere nel foglio un effetto `esilia` / `se` (come Pane e sale). Per il primo serve un mattoncino nuovo (contatore degli antenati) quando arriverà la stirpe.
7. **Lingua del codice**: hai chiesto perché è in italiano. Seguo la convenzione di `CLAUDE.md` (identificatori e commenti in italiano, come il design e i dati). Se preferisci l'inglese conviene deciderlo presto: ora il cambio costa poco.

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
- **Validatore in GDScript, non in Python**: il design vuole il validatore anche all'avvio del gioco in modalità debug; scritto in `core/` serve a entrambi. Lo script da terminale è solo un involucro.
- **Coerenza tra `stati.json` e le ancore** (Radici +2, Fattura 7 e 30%) non controllata: i valori sono scritti due volte (foglio e stati). Si potrebbe far leggere agli stati i valori delle ancore; per ora è un rischio noto.
- **Push su GitHub**: il primo push falliva con HTTP 400 (pacchetto grande per GUT); risolto con `git config http.postBuffer 524288000`, solo nella configurazione locale del repository.
- **Nomi dei campi dello schema scritti nel codice** (`effetto["valore"]`, `d.get("vita")`, le chiavi del riepilogo e del registro): li considero lo schema dei dati, non identificatori interni, e non li ho spostati in `Id`. Spostarli renderebbe il codice molto meno leggibile (`effetto[Id.VALORE]`). Sono invece in `Id` tutti i **valori** che quei campi possono assumere. Se preferisci centralizzare anche i nomi dei campi, è un lavoro meccanico.
- **Test con stringhe letterali**: i test scrivono effetti e impostazioni come stringhe (`{"tipo": "danno"}`), come fanno i JSON; il motore li accetta perché converte sempre con `StringName(...)`.
- ~~**Quale intenzione potenzia la forma divorata**: l'intenzione con più danno~~ — superata da D62 (T2.8): ora la indica il foglio.
- **Obiettivo di vita persa**: le risposte dicono che le Ancore (righe 8-9) sono passate a 8-12%, ma nel foglio le righe "Vita persa obiettivo" (9-10) dicono ancora 10% e 15%. Per la taratura uso gli obiettivi per forma della scheda Forme fattura (base 8-12%), che sono più precisi; le Ancore restano esportate così come sono.
- **"+1 a pesca o cariche"** (D43) per una carta senza punti che ha sia pesca sia cariche (es. *Lamento funebre*): +1 solo al primo dei due effetti nell'ordine della carta. Due evoluzioni = la regola applicata due volte, arrotondando ogni volta (16 → 21 → 27).
- **Carte "ereditate" nei mazzi di riferimento**: le Radici potenziano solo le carte ereditate, e il foglio non dice quali lo sono. In simulazione considero ereditate le carte con livello ≥ 1 (sono per forza passate di generazione); le carte di famiglia di livello 0 contano come nuove. È la scelta prudente: sottostima un po' le Radici.
- **Obiettivo di turni esatto** ("4" nella forma base): lo tratto come 3,5-4,5, perché una media non è mai esattamente un intero.
- **Soglia della strategia ragionevole: 15%** della vita massima (`GiocatoreAutomatico.SOGLIA_DIFESA`). È una scelta mia, non del design; il report dice qual è.
- **Commit della configurazione iniziale**: `CLAUDE.md`, `project.godot`, `.claude/settings.json`, `.editorconfig`, `.gitattributes`, l'icona e la `.gitignore` modificata erano non tracciati; li ho inclusi nel commit di T0.1.

## Registro dei compiti

### T2.12 — Simulazione contro i mazzi di riferimento ✅ (Tappa 2d, D65)
- `GiocatoreAutomatico`: tre strategie (enum `Strategia`). Nuova **ragionevole**: gioca prima le carte che preparano (pesca, Radici); si difende solo da un colpo oltre il 15% della vita massima o letale, e blocca solo finché il danno resta sopra quella soglia; attacca subito se può uccidere il nemico nel turno.
- `core/simulazione/simulatore.gd` (`Simulatore`): mazzo di riferimento di una fase, scenario di N combattimenti con le misure, statistiche e distanza dagli obiettivi; lo usano il report e la taratura.
- `strumenti/simula.gd` riscritto: forma × mazzo della sua fase × 3 età × 3 strategie × 4 nemici, 1000 combattimenti per riga (circa 3,5 minuti), riepilogo con la distanza dagli obiettivi.
- **Risultati** (strategia ragionevole): forma base nei turni per tutti, vita persa solo la Pantafica dentro; toccata quasi tutta nei turni, Lupenaro (35%) e Pantafica (18%) sopra la vita obiettivo; **divorata tutta fuori, sul lato "troppo difficile"** (5,3-6,2 turni; vita persa 24-77%). La Janara non toglie mai vita al giocatore (solo alla casa).
- Test: 9 nuovi (strategie e simulatore). 202 test verdi.

### T2.11 — Invecchiamento delle carte ✅ (Tappa 2d, D43)
- `core/eredita/invecchiamento.gd` (`Invecchiamento`): l'evoluzione "Più forte" come regola pura. +30% (dal foglio, `invecchiamento.piu_forte_aumento`) ai valori in punti, arrotondati; se la carta non ha punti, +1 alla pesca o alle cariche di uno stato. Energia, scarta, esilia, rimuovi stato non cambiano. "Tradizione" non è implementata (errore se richiesta).
- `StatoCombattimento.nuova_carta()` applica le evoluzioni alle carte con livello > 0; nelle impostazioni del mazzo si può dare l'elenco (`evoluzioni`), altrimenti è "Più forte" ripetuta per il livello. I dati del catalogo non vengono toccati.
- Esempi coi dati veri: *Rimandare la fattura* di famiglia 21 danni, degli avi 27; *Aglio* di famiglia 7 blocco; *Invocare gli avi* di famiglia 4 danni.
- Test: `test/eredita/test_invecchiamento.gd` (9 test). 193 test verdi.

### T2.10 — Mazzi di riferimento e obiettivi delle forme ✅ (Tappa 2d, D65)
- `esporta.py`: nuova sezione `mazzi_riferimento` in `bilanciamento.json` (`{fase: {generazione, carte: [{carta, copie, livello}]}}`; il livello si legge come numero o con l'etichetta della scheda Invecchiamento: "di famiglia" = 1, "degli avi" = 2) e, per ogni forma, `obiettivi` (turni e vita persa, min e max) e `mazzo_riferimento`. Le righe di nota della scheda Forme fattura vengono saltate.
- **`bilanciamento.json` passa allo schema 2**; il caricatore ha ora le versioni supportate per file (`SCHEMI_BILANCIAMENTO = [2]`) e rifiuta lo schema 1.
- Validatore: carte dei mazzi esistenti, livelli tra 0 e il livello massimo della scheda Invecchiamento, copie positive, ogni forma con un mazzo esistente e obiettivi coerenti (minimo ≤ massimo). 0 errori sui dati attuali.
- Test: 5 nuovi (caricatore e validatore). 184 test verdi.

### T2.9 — Simulazione rifatta, con la forma divorata ✅ (fine Tappa 2c)
- `strumenti/simula.gd`: nuovo scenario "Forma divorata" (tutti i nemici normali, giovinezza / età adulta / vecchiaia, strategia prudente e solo attacco) che misura dal registro il danno subito a ogni esecuzione dell'intenzione potenziata e quante sconfitte chiude.
- `docs/report-simulazione.md`: tabelle aggiornate, confronto con la Tappa 2b, osservazioni.
- **Forma base**: cambia solo il Lupenaro (Ululato 6): 6,9-8,0 turni e 15-17% di vita persa con la strategia prudente (prima 7,5-8,4 e 16-20%).
- **Il Morso della luna divorato (55) è letale?** Da solo a vita piena no, in nessuna età (vita minima 60; il colpo più forte subito è stato 51, perché il blocco ne toglie sempre un po'). **Ma chiude quasi tutti i combattimenti contro il Lupenaro divorato con il mazzo base**: in vecchiaia è il colpo finale nel 99,9% dei combattimenti (strategia prudente) e nel 58% (solo attacco); in età adulta la strategia prudente vince l'1% dei combattimenti. Gli altri nemici divorati costano molta vita (Pantafica 45-66%, Munaciello 18-46%) ma raramente uccidono. Limite: è il mazzo della prima generazione, mentre la forma divorata arriva dalla quinta.

### T2.8 — Intenzione potenziata dai dati ✅ (Tappa 2c, D62, D63)
- `esporta.py` legge la colonna O "Potenziata in divorata" (`sì` o vuoto; altro = errore) e scrive `forme.divorata.intenzioni_potenziate` nel nemico. Dal foglio: Lupenaro `morso_della_luna`, Janara `assalto_alla_casa`, Pantafica `peso_sul_cuore`, Munaciello `sgambetto`; la Janara Madre nessuna.
- Il motore **non indovina più**: senza il dato nessuna intenzione è potenziata. Tolta la funzione che sceglieva l'intenzione con più danno.
- Il caricatore controlla che il campo sia un elenco di id; il validatore che gli id esistano e avvisa se sono più di uno (D62: al massimo uno per nemico).
- Riesportazione: cambiano solo l'Ululato (10 → 6, D63) e le intenzioni potenziate. Validatore a 0 errori.
- Test: i valori divorati calcolati dal motore coincidono con la colonna J del foglio (Morso della luna 55, Assalto alla casa 25, Peso sul cuore 25, Sgambetto 20); più test sul dato mancante e sui controlli. 179 test verdi.

### T2.7 — Simulazione rifatta ✅ (fine Tappa 2b)
- `docs/report-simulazione.md` rigenerato con i dati nuovi (1000 combattimenti per nemico e per scenario) e con la sezione **Prima / dopo** (turni medi, vita persa, casa persa) composta dal report precedente.
- `strumenti/simula.gd`: nuovo parametro `--turni-obiettivo` (per le Masciare 4, D58; senza parametro l'ancora del foglio).
- **Risultati**: strategia "difende sempre" 4,2-5,8 turni contro Janara, Pantafica e Munaciello (prima 5-8), Lupenaro ancora 7,5-8,4; strategia "solo attacco" 3,3-3,5 turni per tutti (prima 4-5). L'obiettivo dei 4 turni ora sta **dentro la forbice** tra le due strategie per tutti i nemici. Vita persa: Lupenaro 16-21% (sopra la fascia), Pantafica 1-10%, Munaciello 0-5%; la Janara colpisce solo la casa (1-15 punti su 35, mai a 0). Nessun numero corretto.

### T2.6 — Riesportazione e forma divorata ✅ (Tappa 2b, D58, D60)
- Dati riesportati dal foglio (in T2.5, poi confermati senza differenze): efficienza 0,6 → nemici normali **54** di vita, Tiranno **432**; danni dei nemici +25% (Morso 15, Morso della luna 28, Colpo 18…); G = 3 nell'economia; *Ricordo di {antenato}* con `esilia`; scheda Forme fattura con `divorata.intenzione_potenziata = 1.5` (cella D6).
- Forma divorata: l'intenzione potenziata ha i valori in punti × 1,5, oltre ai moltiplicatori globali (es. 22 × 1,5 × 1,3 = 42,9 → 43). Il valore resta decimale fino al calcolo finale, così si arrotonda una volta sola. Le intenzioni aggiunte dalle forme non vengono potenziate. Il registro annota quale intenzione è potenziata.
- Il validatore controlla che le `intenzioni_potenziate` esistano. **0 errori**, 1 avviso (*Il nome del morto*, noto).
- Test: 5 nuovi in `test/nemici/test_nemici.gd`. 175 test verdi.

### T1.9 — Identificatori centralizzati ✅ (Tappa 2b, D57)
- `core/id.gd` (`Id`): tutti gli identificatori interni come costanti `StringName` (`&"danno"`), con gli elenchi ammessi: tipi di effetto (in e fuori combattimento), bersagli, zone e modi, eventi, momenti del lascito, tipi di stato e di carta, comportamenti, livelli, forme, età, operazioni, durate, proprietà, tipi di oggetto e filtri dei modificatori, voci del registro. Un nome usato in più ruoli (es. `mano`) è una sola costante.
- Motore, simulazione e strumenti usano solo `Id.…`: tolti gli elenchi duplicati (`Mattoncini.TIPI`, `Modificatore.DURATE`, `EventiGioco.TUTTI`, quelli del validatore). `EventiGioco` ora è solo il bus.
- `Caricatore.normalizza()` converte le stringhe dei JSON in `StringName` e **rifiuta i valori sconosciuti** (con il percorso dell'errore, es. `carta a: bersaglio sconosciuto 'lune'`). Il validatore la riusa: un'unica fonte per i controlli sui tipi. Anche i dati di prova dei test passano da qui.
- Il nuovo controllo ha trovato subito un problema vero: la riga "Divorata: moltiplicatore dell'intenzione potenziata" della scheda Forme fattura veniva esportata come una quarta forma. `esporta.py` ora la legge come `forme.divorata.intenzione_potenziata = 1.5` e si ferma con un errore su righe sconosciute.
- Test: 8 nuovi in `test/dati/test_caricatore.gd`. 170 test verdi.

### T2.5 — La culla diventa la casa ✅ (Tappa 2b, D59)
- Rinominati in codice, dati, testi, test e strumenti: `Culla` → `Casa` (`core/combattimento/casa.gd`), `culla` → `casa`, `se_o_culla` → `se_o_casa`, `attacco_culla` → `attacco_casa`, `predatore_culla` → `predatore_casa`. Testo: "Casa" / "Home".
- La casa è presente **in tutte le età**: tolta la proprietà `attiva` e ogni controllo "culla inattiva". Stesse regole: a 0 un tratto negativo (massimo uno per combattimento) e torna a metà. Senza valori nelle impostazioni prende la vita dal bilanciamento (35).
- Dati rigenerati dal foglio: il foglio usava già i nomi nuovi, quindi per togliere "culla" dai JSON l'unico modo corretto era riesportare. **Con la riesportazione sono arrivati anche i numeri nuovi** (vita 54, danni +25%, G = 3, *Ricordo* con `esilia`): il compito T2.6 completa il lavoro (forma divorata e test).
- Rimossi 2 test sulla culla inattiva, aggiunto un test sulla casa sempre presente. 162 test verdi; validatore a 0 errori.
- "culla" resta solo nei documenti storici (diario, risposte, piano) e nel vecchio report di simulazione, che T2.7 riscrive.

### T2.4 — Simulazione ✅ (fine Tappa 2)
- `core/simulazione/giocatore_automatico.gd` (`GiocatoreAutomatico`): la strategia semplice del piano (difende se l'intenzione è un attacco, altrimenti gioca la carta con più danni sul nemico più debole), più una variante "solo attacco" come riferimento. Test in `test/simulazione/`.
- `strumenti/simula.gd`: 1000 combattimenti per nemico normale e per età (giovinezza ed età adulta), mazzo base delle Masciare, dati veri. 16 secondi in tutto.
- **Risultati** (`docs/report-simulazione.md`): vittorie 100%; **turni medi 5-8** (ancora: 3); **vita persa 0-9%** (ancora: 10-15%). Anche attaccando soltanto si resta a 4-5 turni: il mazzo base fa circa 16-20 danni a turno, l'ancora ne presume 24. La Janara non toglie mai vita al giocatore (colpisce solo la culla). Nessun numero corretto, come da piano.

### T2.3 — Validatore ✅
- `core/dati/validatore.gd` (`Validatore`): riferimenti (stati, carte, nemici evocati, intenzioni delle sequenze, mazzi base), tipi di effetto e bersagli (elenchi in `Mattoncini.TIPI` e `Mattoncini.BERSAGLI`, un'unica fonte), effetti fuori combattimento ammessi solo nel Lascito, eventi degli agganci, filtri e durate dei modificatori, chiavi di testo. Budget fuori soglia = avviso.
- `strumenti/valida.gd` + `strumenti/valida.sh [--correggi]`: con `--correggi` aggiunge le chiavi mancanti a `testi.csv` con il nome provvisorio del foglio.
- Eseguito sui dati attuali: aggiunte 28 chiavi (23 carte, 5 nemici); ora **0 errori, 1 avviso** (*Il nome del morto* troppo debole, già noto). Le traduzioni inglesi sono vuote.
- Test: `test/dati/test_validatore.gd` (11 test, compreso "i dati attuali sono validi").

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
