class_name Caricatore
extends RefCounted
## Legge i file di dati (JSON) e costruisce il Catalogo.
## Controlla la versione di schema di ogni file: un file con uno schema non supportato non si carica.

const SCHEMI_SUPPORTATI := [1]

const GENERATI := "res://data/generati/"
const MANUALI := "res://data/manuali/"

var errori: PackedStringArray = []


## Carica tutto; restituisce null se c'è almeno un errore (vedi `errori`).
func carica(cartella_generati: String = GENERATI, cartella_manuali: String = MANUALI) -> Catalogo:
	errori.clear()
	var catalogo := Catalogo.new()
	var carte := leggi(cartella_generati + "carte.json")
	var nemici := leggi(cartella_generati + "nemici.json")
	var bilanciamento := leggi(cartella_generati + "bilanciamento.json")
	var stati := leggi(cartella_manuali + "stati.json")
	if not errori.is_empty():
		return null
	catalogo.carte = Catalogo.indicizza(carte.get("carte", []))
	catalogo.nemici = Catalogo.indicizza(nemici.get("nemici", []))
	catalogo.stati = Catalogo.indicizza(stati.get("stati", []))
	catalogo.bilanciamento = bilanciamento
	return catalogo


## Legge un file JSON e controlla lo schema. In caso di problemi aggiunge un errore e restituisce {}.
func leggi(percorso: String) -> Dictionary:
	if not FileAccess.file_exists(percorso):
		errori.append("File mancante: " + percorso)
		return {}
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(percorso)) != OK:
		errori.append("%s: JSON non valido alla riga %d (%s)" % [percorso, json.get_error_line(), json.get_error_message()])
		return {}
	if not (json.data is Dictionary):
		errori.append(percorso + ": il file deve contenere un oggetto")
		return {}
	var dati: Dictionary = json.data
	if not dati.has("schema"):
		errori.append(percorso + ": manca il campo schema")
		return {}
	if not (int(dati["schema"]) in SCHEMI_SUPPORTATI):
		errori.append("%s: schema %s non supportato (supportati: %s)" % [percorso, str(_interi(dati["schema"])), str(SCHEMI_SUPPORTATI)])
		return {}
	return _interi(dati)


## JSON.parse_string legge tutti i numeri come float: rimette interi quelli che lo sono,
## così i confronti e la stampa restano naturali (12, non 12.0).
static func _interi(valore: Variant) -> Variant:
	if valore is float and is_equal_approx(valore, roundf(valore)) and absf(valore) < 1e15:
		return int(valore)
	if valore is Array:
		return valore.map(func(x: Variant) -> Variant: return _interi(x))
	if valore is Dictionary:
		var copia := {}
		for k in valore:
			copia[k] = _interi(valore[k])
		return copia
	return valore
