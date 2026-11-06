class_name Invecchiamento
extends RefCounted
## Le evoluzioni di una carta di famiglia che invecchia (D43).
## "Più forte": +aumento (scheda Invecchiamento, 30%) ai valori in punti (danno, blocco, cura),
## arrotondati; se la carta non ha valori in punti, +1 alla pesca o alle cariche di uno stato
## (il primo effetto di quel tipo). Energia, scarta, esilia e gli altri effetti non cambiano.
## "Tradizione" (effetto della famiglia della carta) non è ancora implementata.


## Restituisce una copia dei dati della carta con le evoluzioni applicate, nell'ordine.
static func applica(dati: Dictionary, evoluzioni: Array, aumento: float) -> Dictionary:
	var risultato := dati.duplicate(true)
	for evoluzione in evoluzioni:
		match StringName(evoluzione):
			Id.PIU_FORTE:
				risultato = piu_forte(risultato, aumento)
			_:
				push_error("Evoluzione non implementata: " + str(evoluzione))
	return risultato


## Le evoluzioni di una carta di cui si conosce solo il livello: "Più forte" ripetuta.
static func evoluzioni_predefinite(livello: int) -> Array:
	var risultato := []
	for i in maxi(0, livello):
		risultato.append(Id.PIU_FORTE)
	return risultato


static func piu_forte(dati: Dictionary, aumento: float) -> Dictionary:
	var risultato := dati.duplicate(true)
	var effetti: Array = risultato.get("effetti", [])
	var in_punti := effetti.filter(func(e: Dictionary) -> bool:
		return StringName(e.get("tipo", "")) in Id.EFFETTI_IN_PUNTI and e.has("valore"))
	if not in_punti.is_empty():
		for e: Dictionary in in_punti:
			e["valore"] = roundi(float(e["valore"]) * (1.0 + aumento))
		return risultato
	for e: Dictionary in effetti:
		var tipo := StringName(e.get("tipo", ""))
		if tipo == Id.PESCA or tipo == Id.APPLICA_STATO:
			e["valore"] = int(e.get("valore", 1)) + 1
			break
	return risultato
