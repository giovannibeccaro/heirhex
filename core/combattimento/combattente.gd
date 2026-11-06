class_name Combattente
extends RefCounted
## Chi può subire danni in combattimento: il giocatore, la culla, un nemico.

var id: String
var nome: String          ## chiave di testo
var vita: int
var vita_max: int
var blocco: int = 0
var stati: Dictionary = {}  ## id stato -> cariche (int)


func _init(p_id: String = "", p_vita_max: int = 1, p_nome: String = "") -> void:
	id = p_id
	nome = p_nome
	vita_max = p_vita_max
	vita = p_vita_max


func e_vivo() -> bool:
	return vita > 0


func cariche(id_stato: String) -> int:
	return int(stati.get(id_stato, 0))


func ha_stato(id_stato: String) -> bool:
	return cariche(id_stato) > 0


## Percentuale di vita rimasta (0..1).
func quota_vita() -> float:
	if vita_max <= 0:
		return 0.0
	return float(vita) / float(vita_max)
