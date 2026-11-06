class_name EventiGioco
extends RefCounted
## Gli eventi di gioco a cui si agganciano stati, modificatori, amuleti, lasciti.
## Ogni evento porta un dizionario di dati; "chi" è il combattente interessato (se c'è).

const INIZIO_COMBATTIMENTO := "inizio_combattimento"
const FINE_COMBATTIMENTO := "fine_combattimento"
const INIZIO_TURNO := "inizio_turno"
const FINE_TURNO := "fine_turno"
const CARTA_GIOCATA := "carta_giocata"
const SOGLIA_RAGGIUNTA := "soglia_raggiunta"

const TUTTI := [INIZIO_COMBATTIMENTO, FINE_COMBATTIMENTO, INIZIO_TURNO, FINE_TURNO, CARTA_GIOCATA, SOGLIA_RAGGIUNTA]

var _ascoltatori: Dictionary = {}   ## evento -> Array[Callable]


## Registra una funzione chiamata con (dati: Dictionary) quando l'evento accade.
## Usare metodi di oggetti (Callable "obj.metodo"), non lambda che catturano il combattimento.
func ascolta(evento: String, funzione: Callable) -> void:
	assert(evento in TUTTI, "Evento sconosciuto: " + evento)
	if not _ascoltatori.has(evento):
		_ascoltatori[evento] = []
	_ascoltatori[evento].append(funzione)


func emetti(evento: String, dati: Dictionary) -> void:
	for funzione: Callable in _ascoltatori.get(evento, []):
		if funzione.is_valid():
			funzione.call(dati)
