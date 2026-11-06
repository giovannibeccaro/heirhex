# Heirhex (nome provvisorio): roguelite deckbuilder del mazzo di famiglia

## Il gioco in breve
Roguelite deckbuilder a turni ambientato in un paese inventato del Sud Italia, con il folklore meridionale (janare, munaciello, anime pezzentelle). Il mazzo appartiene alla **famiglia**: ogni personaggio vive una vita divisa in età (infanzia, giovinezza, età adulta, vecchiaia), poi muore; al testamento porta nella tomba l'**obolo** (la carta più giocata) e una percentuale delle carte di famiglia; il resto passa all'erede. Le carte invecchiano, il genitore torna come anima pezzentella, e il Tiranno (la Janara Madre) si sconfigge in più generazioni.

## Dove sta il design (fonte di verità)
Cartella Google Drive sul Mac:
`/Users/giovannibeccaro/Library/CloudStorage/GoogleDrive-gio.beccaro@gmail.com/Il mio Drive/Traducila/Game Dev`

Leggi prima:
1. `README.md` (indice e regole della cartella)
2. `01-visione/concept.md`
3. `05-decisioni/registro-decisioni.md` (tutte le decisioni con il perché)
4. `06-prototipo/prototipo.md`, `06-prototipo/piano-sviluppo.md`, `06-prototipo/schemi-dati.md`
5. Il file di `02-design/` che riguarda il compito della sessione (es. `combattimento.md`)

I numeri vivono in `06-prototipo/bilanciamento.xlsx`. **Non modificare i documenti di design** se Giovanni non lo chiede: se un compito fa emergere un dubbio o un'incoerenza di design, segnalalo e chiedi.

## Tecnologia
- **Godot 4.7, GDScript** (non C#). Renderer **Compatibility** (serve l'esportazione web per i playtest).
- Test automatici con **GUT** (Godot Unit Test).
- Mac, Apple Silicon.

## Architettura (decisa, vedi D25, D31, D56)
- `core/` — **il motore delle regole**: classi GDScript pure (`RefCounted`), **nessuna dipendenza da nodi, scene o grafica**. Combattimento, mattoncini degli effetti, stati, modificatori, memoria della stirpe, testamento. Deve poter girare senza grafica (`godot --headless`) per test e simulazioni.
- `ui/` — scene e script dell'interfaccia: leggono lo stato del motore e inviano azioni. Nessuna regola di gioco qui.
- `data/generati/` — JSON prodotti dallo script di esportazione dal foglio di calcolo. **Mai modificarli a mano.**
- `data/manuali/` — JSON scritti a mano (eventi, stati, modificatori, memoria).
- `testi/testi.csv` — tutti i testi (colonne `chiave,it,en`). Nel codice e nei dati solo chiavi.
- `strumenti/` — script di esportazione (Python) e validatore.
- `test/` — test GUT, specchio di `core/`.

## Regole di scalabilità (D25)
1. Il codice non conosce i contenuti: nessun nome di carta, nemico o evento nel codice.
2. Gli effetti sono **mattoncini** combinabili; se ne aggiunge uno solo quando nessuna combinazione basta.
3. Un **unico sistema di modificatori** (ordine fisso: somma → moltiplica → imposta).
4. Le meccaniche si agganciano a **eventi di gioco** (inizio turno, carta giocata, fine combattimento, passaggio di generazione).
5. Il codice non compone mai frasi grammaticali (D41, D42).
6. Salvataggi con numero di versione.

## Convenzioni
- Identificatori in **italiano senza accenti**, coerenti con il design e con i dati (`stirpe`, `obolo`, `culla`, `applica_stato`). `snake_case` per funzioni e variabili, `PascalCase` per le classi.
- Tipizzazione statica di GDScript ovunque possibile.
- **Niente stringhe scritte a mano sparse nel codice per gli identificatori interni** (bersagli, tipi di effetto, stati, eventi di gioco): sono definiti **una sola volta** come `enum` o costanti `StringName` in un file dedicato (es. `core/id.gd`). Nei JSON restano stringhe leggibili; il caricatore dei dati le converte e le valida, così un errore di battitura emerge al caricamento e non a metà partita.
- Commenti brevi, in italiano.

## Come lavoriamo
- Giovanni è frontend developer, nuovo al game development: **spiega le scelte specifiche di Godot** quando le introduci.
- Ritmo: una sessione da circa 3 ore a settimana, **un obiettivo piccolo e verificabile** per sessione (tappe in `piano-sviluppo.md`).
- **Prima il motore con i test, poi l'interfaccia.**
- A fine sessione: test verdi, gioco mai lasciato rotto, commit con un messaggio chiaro.

## Modalità autonoma
Quando Giovanni chiede di lavorare in autonomia, segui `docs/PIANO_AUTONOMO.md`: lì le regole cambiano (non chiedere, annota nel diario `docs/DIARIO.md`, lavora sul ramo `autonomo/...`, fermati solo nei casi indicati).
