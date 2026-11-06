class_name Culla
extends Combattente
## La culla: seconda barra di vita dall'età adulta.
## A 0 l'erede riceve un tratto negativo (massimo uno per combattimento) e la culla torna a metà.

var attiva: bool = false
## Tratti negativi causati in questo combattimento (0 o 1).
var tratti_negativi: int = 0


func _init(p_vita_max: int = 1, p_attiva: bool = false) -> void:
	super._init("culla", p_vita_max, "combattimento.culla")
	attiva = p_attiva
