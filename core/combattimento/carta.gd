class_name Carta
extends RefCounted
## Una copia di carta dentro un combattimento. I dati vengono dal catalogo (JSON).

var uid: int              ## unico nel combattimento
var id: String            ## id della carta nei dati
var dati: Dictionary
var ereditata: bool = false
var livello: int = 0


func _init(p_uid: int = 0, p_dati: Dictionary = {}, p_ereditata: bool = false, p_livello: int = 0) -> void:
	uid = p_uid
	dati = p_dati
	id = str(p_dati.get("id", ""))
	ereditata = p_ereditata
	livello = p_livello


func costo_base() -> int:
	return int(dati.get("costo", 0))


## Le carte negative sono ingiocabili, salvo "giocabile": true nei dati.
func giocabile() -> bool:
	if dati.has("giocabile"):
		return bool(dati["giocabile"])
	return dati.get("tipo", "") != "negativa"


func effetti() -> Array:
	return dati.get("effetti", [])


func esilia_dopo_uso() -> bool:
	return bool(dati.get("esilia_dopo_uso", false))


func tag() -> Array:
	return dati.get("tag", [])
