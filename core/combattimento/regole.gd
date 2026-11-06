class_name RegoleCombattimento
extends RefCounted
## Numeri del combattimento che non appartengono a una carta o a un nemico.
## I valori predefiniti sono quelli del design; il caricatore li legge da bilanciamento.json.

var energia_per_turno: int = 3
## Quota del blocco che resta all'inizio del turno di chi lo possiede.
## 0,5 = blocco dimezzato [DA PROVARE]; 0 = il blocco svanisce (standard del genere).
var quota_blocco_mantenuta: float = 0.5
## Massimo di carte in mano: oltre, le carte pescate restano nel mazzo.
var mano_limite: int = 10
## Massimo di nemici in campo (limita "evoca").
var nemici_max: int = 5


static func da_dizionario(d: Dictionary) -> RegoleCombattimento:
	var r := RegoleCombattimento.new()
	r.energia_per_turno = int(d.get("energia_per_turno", r.energia_per_turno))
	r.quota_blocco_mantenuta = float(d.get("quota_blocco_mantenuta", r.quota_blocco_mantenuta))
	r.mano_limite = int(d.get("mano_limite", r.mano_limite))
	r.nemici_max = int(d.get("nemici_max", r.nemici_max))
	return r
