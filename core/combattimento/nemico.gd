class_name Nemico
extends Combattente
## Un nemico in combattimento.

var uid: int
var dati: Dictionary
var intenzione: Dictionary = {}   ## intenzione mostrata per il prossimo turno
var passo_sequenza: int = 0       ## posizione nella sequenza (comportamento "sequenza")


func _init(p_uid: int = 0, p_dati: Dictionary = {}, p_vita_max: int = -1) -> void:
	var v := p_vita_max if p_vita_max > 0 else int(p_dati.get("vita", 1))
	super._init(str(p_dati.get("id", "")), v, str(p_dati.get("nome", "")))
	uid = p_uid
	dati = p_dati
