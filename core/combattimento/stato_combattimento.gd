class_name StatoCombattimento
extends RefCounted
## Tutto lo stato di un combattimento in corso. Solo dati: le regole stanno in Combattimento.

var casuale: Casuale
var regole: RegoleCombattimento
var catalogo: Catalogo
var modificatori := SistemaModificatori.new()
## Agganci esterni (lasciti, amuleti, presenze): { quando, effetti }, eseguiti dal giocatore.
var agganci: Array = []

var giocatore: Combattente
var casa: Casa
var nemici: Array[Nemico] = []

var mazzo: Array[Carta] = []   ## l'ultima carta è la cima (si pesca da lì)
var mano: Array[Carta] = []
var scarti: Array[Carta] = []
var esilio: Array[Carta] = []
var rubate: Array[Carta] = []  ## rubate dai nemici per il resto del combattimento
var ultima_mano: Array[Carta] = []  ## la mano scartata a fine turno (serve al furto)

var energia: int = 0
var mano_dimensione: int = 5   ## carte pescate a inizio turno (dipende dall'età)
var turno: int = 0             ## 1 = primo turno del giocatore
var giocate: Dictionary = {}   ## uid carta -> volte giocata (serve all'obolo)

var _prossimo_uid_carta: int = 1
var _prossimo_uid_nemico: int = 1


func _init(p_catalogo: Catalogo, p_casuale: Casuale, p_regole: RegoleCombattimento = null) -> void:
	catalogo = p_catalogo
	casuale = p_casuale
	regole = p_regole if p_regole != null else RegoleCombattimento.new()


## Crea una copia di carta dal catalogo, con uid nuovo.
func nuova_carta(id_carta: String, ereditata: bool = false, livello: int = 0) -> Carta:
	var dati := catalogo.carta(id_carta)
	assert(not dati.is_empty(), "Carta sconosciuta: " + id_carta)
	var c := Carta.new(_prossimo_uid_carta, dati, ereditata, livello)
	_prossimo_uid_carta += 1
	return c


## Crea un nemico dal catalogo, con uid nuovo (non lo aggiunge al campo).
func nuovo_nemico(id_nemico: String) -> Nemico:
	var dati := catalogo.nemico(id_nemico)
	assert(not dati.is_empty(), "Nemico sconosciuto: " + id_nemico)
	var n := Nemico.new(_prossimo_uid_nemico, dati)
	_prossimo_uid_nemico += 1
	return n


func nemici_vivi() -> Array[Nemico]:
	var vivi: Array[Nemico] = []
	for n in nemici:
		if n.e_vivo():
			vivi.append(n)
	return vivi


func nemico_per_uid(uid: int) -> Nemico:
	for n in nemici:
		if n.uid == uid:
			return n
	return null


func carta_in_mano(uid: int) -> Carta:
	for c in mano:
		if c.uid == uid:
			return c
	return null


## Tutte le carte del combattimento, in qualsiasi zona.
func tutte_le_carte() -> Array[Carta]:
	var tutte: Array[Carta] = []
	tutte.append_array(mazzo)
	tutte.append_array(mano)
	tutte.append_array(scarti)
	tutte.append_array(esilio)
	tutte.append_array(rubate)
	return tutte
