class_name IntelligenzaNemici
extends RefCounted
## Sceglie l'intenzione che un nemico mostrerà per il prossimo turno.


## Restituisce l'intenzione (dizionario) per il turno indicato.
static func scegli(n: Nemico, turno: int, casuale: Casuale) -> Dictionary:
	var intenzioni: Array = n.dati.get("intenzioni", [])
	if intenzioni.is_empty():
		return {}
	match str(n.dati.get("comportamento", "sequenza")):
		"sequenza":
			return _da_sequenza(n, intenzioni)
		_:
			return intenzioni[casuale.indice(intenzioni.size())]


static func _da_sequenza(n: Nemico, intenzioni: Array) -> Dictionary:
	var sequenza: Array = n.dati.get("sequenza", intenzioni.map(func(i: Dictionary) -> String: return str(i["id"])))
	var id_scelto := str(sequenza[n.passo_sequenza % sequenza.size()])
	n.passo_sequenza += 1
	return cerca(intenzioni, id_scelto)


static func cerca(intenzioni: Array, id: String) -> Dictionary:
	for i in intenzioni:
		if str(i["id"]) == id:
			return i
	push_error("Intenzione sconosciuta: " + id)
	return {}
