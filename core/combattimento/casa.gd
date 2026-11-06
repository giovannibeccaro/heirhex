class_name Casa
extends Combattente
## La casa di famiglia (D59): seconda barra di vita, in tutte le età.
## A 0 l'erede riceve un tratto negativo (massimo uno per combattimento) e la casa torna a metà.

## Tratti negativi causati in questo combattimento (0 o 1).
var tratti_negativi: int = 0


func _init(p_vita_max: int = 1) -> void:
	super._init("casa", p_vita_max, "combattimento.casa")
