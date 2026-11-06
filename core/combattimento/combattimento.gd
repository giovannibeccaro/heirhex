class_name Combattimento
extends RefCounted
## Il combattimento: crea lo stato e applica le regole del turno.
## L'interfaccia (o una simulazione) chiama solo i metodi pubblici: inizia, gioca_carta, termina_turno.

var stato: StatoCombattimento


## impostazioni:
##   seme: int
##   mazzo: Array di id oppure { id, ereditata, livello }
##   nemici: Array di id oppure { id, quota_vita }
##   giocatore: { vita, vita_max, stati }
##   culla: { vita, vita_max, attiva }
##   mano: carte pescate a inizio turno (età)
func _init(catalogo: Catalogo, impostazioni: Dictionary, regole: RegoleCombattimento = null) -> void:
	var casuale := Casuale.new(int(impostazioni.get("seme", 0)))
	stato = StatoCombattimento.new(catalogo, casuale, regole)
	_prepara_giocatore(impostazioni.get("giocatore", {}))
	_prepara_culla(impostazioni.get("culla", {}))
	stato.mano_dimensione = int(impostazioni.get("mano", 5))
	for voce in impostazioni.get("mazzo", []):
		stato.mazzo.append(_crea_carta(voce))
	for voce in impostazioni.get("nemici", []):
		stato.nemici.append(_crea_nemico(voce))
	stato.casuale.mescola(stato.mazzo)


func _prepara_giocatore(d: Dictionary) -> void:
	var vita_max := int(d.get("vita_max", d.get("vita", 100)))
	stato.giocatore = Combattente.new("giocatore", vita_max, "combattimento.giocatore")
	stato.giocatore.vita = int(d.get("vita", vita_max))
	stato.giocatore.stati = (d.get("stati", {}) as Dictionary).duplicate()


func _prepara_culla(d: Dictionary) -> void:
	var vita_max := int(d.get("vita_max", d.get("vita", 1)))
	stato.culla = Culla.new(vita_max, bool(d.get("attiva", false)))
	stato.culla.vita = int(d.get("vita", vita_max))


func _crea_carta(voce: Variant) -> Carta:
	if voce is Dictionary:
		return stato.nuova_carta(str(voce["id"]), bool(voce.get("ereditata", false)), int(voce.get("livello", 0)))
	return stato.nuova_carta(str(voce))


func _crea_nemico(voce: Variant) -> Nemico:
	var d: Dictionary = voce if voce is Dictionary else {"id": str(voce)}
	var n := stato.nuovo_nemico(str(d["id"]))
	if d.has("quota_vita"):
		n.vita = maxi(1, roundi(n.vita_max * float(d["quota_vita"])))
	return n
