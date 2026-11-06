class_name Catalogo
extends RefCounted
## Tutti i contenuti caricati dai dati, indicizzati per id.
## Il motore chiede qui carte, nemici e stati: non conosce i contenuti.

var carte: Dictionary = {}       ## id -> Dictionary
var nemici: Dictionary = {}      ## id -> Dictionary
var stati: Dictionary = {}       ## id -> Dictionary
var bilanciamento: Dictionary = {}


func carta(id: String) -> Dictionary:
	return carte.get(id, {})


func nemico(id: String) -> Dictionary:
	return nemici.get(id, {})


func stato(id: String) -> Dictionary:
	return stati.get(id, {})


## Aggiunge un elenco di elementi con campo "id" al dizionario indicato.
static func indicizza(elenco: Array) -> Dictionary:
	var risultato := {}
	for elemento in elenco:
		risultato[str(elemento["id"])] = elemento
	return risultato
