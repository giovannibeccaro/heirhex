class_name Validatore
extends RefCounted
## Controlla la coerenza dei dati: identificatori noti (tramite Caricatore.normalizza, unica fonte),
## riferimenti a id esistenti, chiavi di testo presenti.
## Gli errori rendono i dati inutilizzabili; gli avvisi segnalano cose da guardare (es. budget).

var errori: PackedStringArray = []
var avvisi: PackedStringArray = []
## Chiavi di testo usate dai dati ma assenti in testi.csv.
var chiavi_mancanti: PackedStringArray = []

var _catalogo: Catalogo
var _testi: Dictionary


## chiavi_testo: chiave -> testo italiano (vedi leggi_testi). Restituisce true se non ci sono errori.
func valida(catalogo: Catalogo, chiavi_testo: Dictionary) -> bool:
	errori.clear()
	avvisi.clear()
	chiavi_mancanti.clear()
	_catalogo = catalogo
	_testi = chiavi_testo
	errori.append_array(Caricatore.normalizza(catalogo))
	for id in catalogo.carte:
		_valida_carta(id, catalogo.carte[id])
	for id in catalogo.nemici:
		_valida_nemico(id, catalogo.nemici[id])
	for id in catalogo.stati:
		_valida_stato(id, catalogo.stati[id])
	_valida_bilanciamento(catalogo.bilanciamento)
	return errori.is_empty()


## Legge testi.csv: chiave -> testo italiano.
static func leggi_testi(percorso: String) -> Dictionary:
	var risultato := {}
	var f := FileAccess.open(percorso, FileAccess.READ)
	if f == null:
		return risultato
	var intestazione := f.get_csv_line()
	var colonna_it := intestazione.find("it")
	while not f.eof_reached():
		var riga := f.get_csv_line()
		if riga.size() > 0 and riga[0] != "":
			risultato[riga[0]] = riga[colonna_it] if colonna_it >= 0 and colonna_it < riga.size() else ""
	return risultato


# --- singoli contenuti ------------------------------------------------------------

func _valida_carta(id: String, c: Dictionary) -> void:
	var dove := "carta " + id
	_testo(dove, c.get("nome", ""))
	_richiesti(dove, c, ["nome", "tipo", "rarita", "costo", "effetti"])
	for e in c.get("effetti", []):
		_effetto(dove, e, false)
	if c.has("lascito"):
		for e in c["lascito"].get("effetti", []):
			_effetto(dove + " (lascito)", e, true)
	var budget: Dictionary = c.get("budget", {})
	if budget.has("esito") and str(budget["esito"]) != "OK":
		avvisi.append("%s: fuori budget (%s, scostamento %s)" % [dove, budget["esito"], str(budget.get("scostamento", "?"))])


func _valida_nemico(id: String, n: Dictionary) -> void:
	var dove := "nemico " + id
	_testo(dove, n.get("nome", ""))
	_richiesti(dove, n, ["nome", "vita", "intenzioni"])
	var ids := _valida_intenzioni(dove, n.get("intenzioni", []))
	for passo in n.get("sequenza", []):
		if not ids.has(passo):
			errori.append("%s: la sequenza cita l'intenzione inesistente '%s'" % [dove, passo])
	if StringName(n.get("comportamento", "")) == Id.SEQUENZA and (n.get("sequenza", []) as Array).is_empty():
		avvisi.append(dove + ": comportamento a sequenza senza campo sequenza (uso l'ordine delle intenzioni)")
	for f in n.get("fasi", []):
		_valida_intenzioni(dove + " (fase)", f.get("intenzioni", []))
	for forma in n.get("forme", {}):
		_valida_intenzioni("%s (forma %s)" % [dove, forma], n["forme"][forma].get("intenzioni_aggiunte", []))


func _valida_intenzioni(dove: String, intenzioni: Array) -> Array:
	var ids := []
	for i in intenzioni:
		var id := str(i.get("id", ""))
		if id == "":
			errori.append(dove + ": intenzione senza id")
		elif ids.has(id):
			errori.append("%s: intenzione ripetuta '%s'" % [dove, id])
		ids.append(id)
		for e in i.get("effetti", []):
			_effetto("%s, intenzione %s" % [dove, id], e, false)
	return ids


func _valida_stato(id: String, s: Dictionary) -> void:
	var dove := "stato " + id
	_testo(dove, s.get("nome", ""))
	if s.has("testo"):
		_testo(dove, s["testo"])
	if StringName(s.get("tipo", "")) == Id.SOGLIA and int(s.get("soglia", 0)) <= 0:
		errori.append(dove + ": stato a soglia senza soglia")
	for a in s.get("agganci", []):
		for e in a.get("effetti", []):
			_effetto(dove, e, false)


func _valida_bilanciamento(b: Dictionary) -> void:
	for casata in b.get("mazzi_base", {}):
		for voce in b["mazzi_base"][casata]:
			_rif_carta("mazzo base " + str(casata), str(voce.get("carta", "")))
	for forma in b.get("forme", {}):
		for campo in ["vita", "danno"]:
			if not b["forme"][forma].has(campo):
				errori.append("forma %s: manca il moltiplicatore %s" % [forma, campo])


# --- pezzi comuni --------------------------------------------------------------------

## Riferimenti degli effetti (i tipi li ha già controllati Caricatore.normalizza).
func _effetto(dove: String, e: Dictionary, _fuori_combattimento_ammesso: bool) -> void:
	var tipo := StringName(e.get("tipo", ""))
	if tipo == Id.APPLICA_STATO or tipo == Id.RIMUOVI_STATO:
		if not _catalogo.stati.has(str(e.get("stato", ""))):
			errori.append("%s: stato inesistente '%s'" % [dove, e.get("stato", "")])
	if tipo == Id.AGGIUNGI_CARTA:
		_rif_carta(dove, str(e.get("carta", "")))
	if tipo == Id.EVOCA and not _catalogo.nemici.has(str(e.get("nemico", ""))):
		errori.append("%s: nemico inesistente '%s'" % [dove, e.get("nemico", "")])


func _rif_carta(dove: String, id: String) -> void:
	if not _catalogo.carte.has(id):
		errori.append("%s: carta inesistente '%s'" % [dove, id])


func _richiesti(dove: String, d: Dictionary, campi: Array) -> void:
	for campo in campi:
		if not d.has(campo):
			errori.append("%s: manca il campo '%s'" % [dove, campo])


func _testo(dove: String, chiave: Variant) -> void:
	var k := str(chiave)
	if k == "":
		errori.append(dove + ": chiave di testo vuota")
	elif not _testi.has(k):
		errori.append("%s: chiave di testo mancante in testi.csv '%s'" % [dove, k])
		if not chiavi_mancanti.has(k):
			chiavi_mancanti.append(k)
