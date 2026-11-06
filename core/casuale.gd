class_name Casuale
extends RefCounted
## Generatore casuale con seme: stesso seme = stessa partita.
## Tutto il caso del motore passa da qui (mai randi() globale né Array.shuffle()).

var _rng := RandomNumberGenerator.new()
var seme: int


func _init(p_seme: int = 0) -> void:
	seme = p_seme
	_rng.seed = p_seme


## Intero tra minimo e massimo, estremi compresi.
func intero(minimo: int, massimo: int) -> int:
	return _rng.randi_range(minimo, massimo)


## Numero tra 0 e 1.
func decimale() -> float:
	return _rng.randf()


## Indice casuale in un elenco di n elementi; -1 se vuoto.
func indice(n: int) -> int:
	if n <= 0:
		return -1
	return _rng.randi_range(0, n - 1)


## Mescola l'array sul posto (Fisher-Yates).
func mescola(elenco: Array) -> void:
	for i in range(elenco.size() - 1, 0, -1):
		var j := _rng.randi_range(0, i)
		var tmp: Variant = elenco[i]
		elenco[i] = elenco[j]
		elenco[j] = tmp


## Indice scelto in proporzione ai pesi; -1 se nessun peso è positivo.
func indice_pesato(pesi: Array) -> int:
	var totale := 0.0
	for p in pesi:
		totale += maxf(float(p), 0.0)
	if totale <= 0.0:
		return -1
	var x := _rng.randf() * totale
	for i in pesi.size():
		var p := maxf(float(pesi[i]), 0.0)
		if x < p:
			return i
		x -= p
	# Arrotondamenti: ultimo peso positivo
	for i in range(pesi.size() - 1, -1, -1):
		if float(pesi[i]) > 0.0:
			return i
	return -1


## Stato interno, per salvataggi e snapshot.
func get_stato() -> int:
	return _rng.state


func set_stato(valore: int) -> void:
	_rng.state = valore
