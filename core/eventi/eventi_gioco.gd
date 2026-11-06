class_name EventiGioco
extends RefCounted
## Il bus degli eventi di gioco (gli eventi sono in Id: Id.INIZIO_TURNO, Id.EVENTI…).
## Ogni evento porta un dizionario di dati; "chi" è il combattente interessato (se c'è).

var _ascoltatori: Dictionary = {}   ## evento -> Array[Callable]


## Registra una funzione chiamata con (dati: Dictionary) quando l'evento accade.
## Usare metodi di oggetti (Callable "obj.metodo"), non lambda che catturano il combattimento.
func ascolta(evento: StringName, funzione: Callable) -> void:
	assert(evento in Id.EVENTI, "Evento sconosciuto: " + evento)
	if not _ascoltatori.has(evento):
		_ascoltatori[evento] = []
	_ascoltatori[evento].append(funzione)


func emetti(evento: StringName, dati: Dictionary) -> void:
	for funzione: Callable in _ascoltatori.get(evento, []):
		if funzione.is_valid():
			funzione.call(dati)
