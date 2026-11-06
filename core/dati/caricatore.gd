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
	errori.append_array(normalizza(catalogo))
	return catalogo if errori.is_empty() else null


# === Conversione degli identificatori ===========================================
# Nei JSON gli identificatori sono stringhe; qui diventano gli StringName di Id.
# Un valore che non esiste in Id è un errore: un refuso emerge al caricamento.

## Converte sul posto gli identificatori del catalogo; restituisce gli errori trovati.
static func normalizza(catalogo: Catalogo) -> PackedStringArray:
	var errori := PackedStringArray()
	for id in catalogo.carte:
		_carta("carta " + str(id), catalogo.carte[id], errori)
	for id in catalogo.nemici:
		_nemico("nemico " + str(id), catalogo.nemici[id], errori)
	for id in catalogo.stati:
		_stato("stato " + str(id), catalogo.stati[id], errori)
	var forme: Dictionary = catalogo.bilanciamento.get("forme", {})
	for forma in forme.keys():
		if not (StringName(forma) in Id.FORME):
			errori.append("bilanciamento: forma sconosciuta '%s'" % forma)
	return errori


## Converte d[campo] in StringName se è tra gli ammessi; altrimenti registra un errore.
static func _id(dove: String, d: Dictionary, campo: String, ammessi: Array[StringName], errori: PackedStringArray, obbligatorio: bool = false) -> void:
	if not d.has(campo):
		if obbligatorio:
			errori.append("%s: manca il campo '%s'" % [dove, campo])
		return
	var valore := StringName(str(d[campo]))
	if not (valore in ammessi):
		errori.append("%s: %s sconosciuto '%s'" % [dove, campo, d[campo]])
		return
	d[campo] = valore


static func _effetti(dove: String, effetti: Array, fuori_combattimento: bool, errori: PackedStringArray) -> void:
	var tipi: Array[StringName] = Id.EFFETTI_COMBATTIMENTO.duplicate()
	if fuori_combattimento:
		tipi.append_array(Id.EFFETTI_FUORI_COMBATTIMENTO)
	for e: Dictionary in effetti:
		_id(dove, e, "tipo", tipi, errori, true)
		_id(dove, e, "bersaglio", Id.BERSAGLI, errori)
		_id(dove, e, "da", Id.ZONE, errori)
		_id(dove, e, "dove", Id.ZONE, errori)
		_id(dove, e, "modo", Id.MODI, errori)
		if e.get("valore") is String:
			_id(dove, e, "valore", [Id.TUTTE] as Array[StringName], errori)
		if e.get("tipo") == Id.APPLICA_MODIFICATORE:
			_id(dove, e, "proprieta", Id.PROPRIETA, errori, true)
			_id(dove, e, "operazione", Id.OPERAZIONI, errori)
			_id(dove, e, "durata", Id.DURATE, errori)


static func _carta(dove: String, c: Dictionary, errori: PackedStringArray) -> void:
	_id(dove, c, "tipo", Id.TIPI_CARTA, errori, true)
	_effetti(dove, c.get("effetti", []), false, errori)
	if c.has("lascito"):
		_id(dove + " (lascito)", c["lascito"], "momento", Id.MOMENTI_LASCITO, errori, true)
		_effetti(dove + " (lascito)", c["lascito"].get("effetti", []), true, errori)


static func _intenzioni(dove: String, intenzioni: Array, errori: PackedStringArray) -> void:
	for i: Dictionary in intenzioni:
		_effetti("%s, intenzione %s" % [dove, i.get("id", "?")], i.get("effetti", []), false, errori)


static func _nemico(dove: String, n: Dictionary, errori: PackedStringArray) -> void:
	_id(dove, n, "comportamento", Id.COMPORTAMENTI, errori)
	_id(dove, n, "livello", Id.LIVELLI, errori)
	_intenzioni(dove, n.get("intenzioni", []), errori)
	for f: Dictionary in n.get("fasi", []):
		_id(dove + " (fase)", f, "comportamento", Id.COMPORTAMENTI, errori)
		_intenzioni(dove + " (fase)", f.get("intenzioni", []), errori)
	var forme: Dictionary = n.get("forme", {})
	for forma in forme.keys():
		if not (StringName(forma) in Id.FORME):
			errori.append("%s: forma sconosciuta '%s'" % [dove, forma])
			continue
		_intenzioni("%s (forma %s)" % [dove, forma], forme[forma].get("intenzioni_aggiunte", []), errori)
		var potenziate: Variant = forme[forma].get("intenzioni_potenziate", [])
		if not (potenziate is Array) or (potenziate as Array).any(func(x: Variant) -> bool: return not (x is String)):
			errori.append("%s: forma %s, intenzioni_potenziate deve essere un elenco di id" % [dove, forma])


static func _stato(dove: String, s: Dictionary, errori: PackedStringArray) -> void:
	_id(dove, s, "tipo", Id.TIPI_STATO, errori, true)
	for a: Dictionary in s.get("agganci", []):
		_id(dove, a, "quando", Id.EVENTI, errori, true)
		_effetti(dove, a.get("effetti", []), false, errori)
	for m: Dictionary in s.get("modificatori", []):
		modificatore(dove, m, errori)


## Converte un modificatore scritto nei dati (usato anche per amuleti, annate, casate).
static func modificatore(dove: String, m: Dictionary, errori: PackedStringArray) -> void:
	_id(dove, m, "proprieta", Id.PROPRIETA, errori, true)
	_id(dove, m, "operazione", Id.OPERAZIONI, errori)
	_id(dove, m, "durata", Id.DURATE, errori)
	var b: Dictionary = m.get("bersaglio", {})
	_id(dove, b, "tipo", Id.TIPI_OGGETTO, errori, true)
	var filtro: Dictionary = b.get("filtro", {})
	for chiave in filtro.keys():
		if not (StringName(chiave) in Id.FILTRI):
			errori.append("%s: filtro sconosciuto '%s'" % [dove, chiave])


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
