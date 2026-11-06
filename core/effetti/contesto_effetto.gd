class_name ContestoEffetto
extends RefCounted
## Chi esegue un effetto e con quali scelte del giocatore.

var sorgente: Combattente          ## chi esegue (giocatore, nemico, portatore dello stato)
var carta: Carta = null            ## la carta giocata, se l'effetto viene da una carta
var scelte: Dictionary = {}        ## scelte del giocatore (nemico bersaglio, se o casa, carte…)
var esilia_carta: bool = false     ## un effetto ha chiesto di esiliare la carta giocata


func _init(p_sorgente: Combattente, p_carta: Carta = null, p_scelte: Dictionary = {}) -> void:
	sorgente = p_sorgente
	carta = p_carta
	scelte = p_scelte
