class_name Nemico
extends Combattente
## Un nemico in combattimento.

var uid: int
var dati: Dictionary
var forma: StringName = Id.BASE      ## Id.FORME (forme della fattura)
var intenzione: Dictionary = {}       ## intenzione mostrata per il prossimo turno
var intenzione_annullata: bool = false
var carte_rubate: Array[int] = []     ## uid delle carte rubate in questo combattimento

## Intenzioni della fase base (dati + aggiunte della forma).
var intenzioni_base: Array = []
## Fasi successive: { sotto_quota_vita, comportamento, intenzioni, sequenza }.
var fasi: Array = []
var fase: int = 0                     ## 0 = base; 1.. = indice in fasi + 1

# Memoria del comportamento
var passo_sequenza: int = 0
var storico: Array[String] = []       ## id delle intenzioni scelte, dalla più vecchia
var ultimo_uso: Dictionary = {}       ## id intenzione -> turno in cui è stata scelta


func _init(p_uid: int = 0, p_dati: Dictionary = {}, p_vita_max: int = -1) -> void:
	var v := p_vita_max if p_vita_max > 0 else int(p_dati.get("vita", 1))
	super._init(str(p_dati.get("id", "")), v, str(p_dati.get("nome", "")))
	uid = p_uid
	dati = p_dati
	intenzioni_base = (p_dati.get("intenzioni", []) as Array).duplicate()
	for f in p_dati.get("fasi", []):
		fasi.append((f as Dictionary).duplicate(true))


## Le intenzioni e il comportamento della fase attuale.
func intenzioni_attive() -> Array:
	return intenzioni_base if fase == 0 else fasi[fase - 1].get("intenzioni", [])


func comportamento_attivo() -> StringName:
	if fase == 0:
		return StringName(dati.get("comportamento", Id.PESATO))
	return StringName(fasi[fase - 1].get("comportamento", Id.PESATO))


func sequenza_attiva() -> Array:
	var origine: Dictionary = dati if fase == 0 else fasi[fase - 1]
	if origine.has("sequenza"):
		return origine["sequenza"]
	return intenzioni_attive().map(func(i: Dictionary) -> String: return str(i["id"]))
