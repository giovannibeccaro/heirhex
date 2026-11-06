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
