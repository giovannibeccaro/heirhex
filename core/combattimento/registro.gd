class_name Registro
extends RefCounted
## Registro di tutte le azioni del combattimento: serve al debug e agli snapshot.
## Ogni voce è un dizionario strutturato; righe() lo trasforma in testo tecnico (non è testo di gioco).

var voci: Array[Dictionary] = []


func aggiungi(turno: int, tipo: String, dati: Dictionary = {}) -> void:
	var voce := {"turno": turno, "tipo": tipo}
	voce.merge(dati)
	voci.append(voce)


func conta(tipo: String) -> int:
	var n := 0
	for v in voci:
		if v["tipo"] == tipo:
			n += 1
	return n


func filtra(tipo: String) -> Array[Dictionary]:
	var risultato: Array[Dictionary] = []
	for v in voci:
		if v["tipo"] == tipo:
			risultato.append(v)
	return risultato


## Una riga di testo tecnico per voce, es. "[T2] danno da=lupo#1 a=giocatore valore=12 ...".
## Serve al debug e agli snapshot: non è testo di gioco e non si traduce.
func righe() -> PackedStringArray:
	var risultato := PackedStringArray()
	for v in voci:
		var parti := PackedStringArray(["[T%d]" % v["turno"], str(v["tipo"])])
		for chiave in v:
			if chiave != "turno" and chiave != "tipo":
				parti.append("%s=%s" % [chiave, _testo(v[chiave])])
		risultato.append(" ".join(parti))
	return risultato


func testo() -> String:
	return "\n".join(righe())


static func _testo(valore: Variant) -> String:
	if valore is Array:
		return "[" + ",".join(valore.map(func(x: Variant) -> String: return str(x))) + "]"
	return str(valore)
