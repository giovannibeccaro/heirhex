class_name Validatore
extends RefCounted
## Controlla la coerenza dei dati: riferimenti a id esistenti, tipi noti, chiavi di testo presenti.
## Gli errori rendono i dati inutilizzabili; gli avvisi segnalano cose da guardare (es. budget).

## Effetti che esistono solo fuori dal combattimento (eventi, lasciti): schemi-dati.md.
const TIPI_FUORI_COMBATTIMENTO := ["grani", "memoria", "ottieni_carta", "rimuovi_carta",
	"ottieni_amuleto", "ottieni_rimedio", "benedici", "vita", "vita_max"]
const TIPI_STATO := ["intensita", "durata", "soglia"]
const COMPORTAMENTI := ["pesato", "sequenza"]
const PROPRIETA := ["costo", "valore_effetti", "vita_max", "mano", "energia", "danno_subito", "prezzo", "ricompensa_grani"]
const FILTRI := ["ereditata", "uid", "id", "tag", "rarita", "tipo", "famiglia", "casata", "ruolo", "livello"]
const MOMENTI_LASCITO := ["inizio_vita", "inizio_combattimento"]

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
		var l: Dictionary = c["lascito"]
		if not (str(l.get("momento", "")) in MOMENTI_LASCITO):
			errori.append("%s: momento del lascito sconosciuto '%s'" % [dove, l.get("momento", "")])
		for e in l.get("effetti", []):
			_effetto(dove + " (lascito)", e, true)
	var budget: Dictionary = c.get("budget", {})
	if budget.has("esito") and str(budget["esito"]) != "OK":
		avvisi.append("%s: fuori budget (%s, scostamento %s)" % [dove, budget["esito"], str(budget.get("scostamento", "?"))])


func _valida_nemico(id: String, n: Dictionary) -> void:
	var dove := "nemico " + id
	_testo(dove, n.get("nome", ""))
	_richiesti(dove, n, ["nome", "vita", "intenzioni"])
	if not (str(n.get("comportamento", "pesato")) in COMPORTAMENTI):
		errori.append("%s: comportamento sconosciuto '%s'" % [dove, n.get("comportamento")])
	var ids := _valida_intenzioni(dove, n.get("intenzioni", []))
	for passo in n.get("sequenza", []):
		if not ids.has(passo):
			errori.append("%s: la sequenza cita l'intenzione inesistente '%s'" % [dove, passo])
	if str(n.get("comportamento", "")) == "sequenza" and (n.get("sequenza", []) as Array).is_empty():
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
	if not (str(s.get("tipo", "")) in TIPI_STATO):
		errori.append("%s: tipo sconosciuto '%s'" % [dove, s.get("tipo", "")])
	if str(s.get("tipo", "")) == "soglia" and int(s.get("soglia", 0)) <= 0:
		errori.append(dove + ": stato a soglia senza soglia")
	for a in s.get("agganci", []):
		if not (str(a.get("quando", "")) in EventiGioco.TUTTI):
			errori.append("%s: aggancio a un evento sconosciuto '%s'" % [dove, a.get("quando", "")])
		for e in a.get("effetti", []):
			_effetto(dove, e, false)
	for m in s.get("modificatori", []):
		_modificatore(dove, m)


func _valida_bilanciamento(b: Dictionary) -> void:
	for casata in b.get("mazzi_base", {}):
		for voce in b["mazzi_base"][casata]:
			_rif_carta("mazzo base " + str(casata), str(voce.get("carta", "")))
	for forma in b.get("forme", {}):
		for campo in ["vita", "danno"]:
			if not b["forme"][forma].has(campo):
				errori.append("forma %s: manca il moltiplicatore %s" % [forma, campo])


# --- pezzi comuni --------------------------------------------------------------------

func _effetto(dove: String, e: Dictionary, fuori_combattimento_ammesso: bool) -> void:
	var tipo := str(e.get("tipo", ""))
	var ammesso := tipo in Mattoncini.TIPI or (fuori_combattimento_ammesso and tipo in TIPI_FUORI_COMBATTIMENTO)
	if not ammesso:
		errori.append("%s: tipo di effetto sconosciuto '%s'" % [dove, tipo])
	if e.has("bersaglio") and not (str(e["bersaglio"]) in Mattoncini.BERSAGLI):
		errori.append("%s: bersaglio sconosciuto '%s'" % [dove, e["bersaglio"]])
	if tipo in ["applica_stato", "rimuovi_stato"]:
		if not _catalogo.stati.has(str(e.get("stato", ""))):
			errori.append("%s: stato inesistente '%s'" % [dove, e.get("stato", "")])
	if tipo == "aggiungi_carta":
		_rif_carta(dove, str(e.get("carta", "")))
	if tipo == "evoca" and not _catalogo.nemici.has(str(e.get("nemico", ""))):
		errori.append("%s: nemico inesistente '%s'" % [dove, e.get("nemico", "")])
	if tipo == "applica_modificatore":
		_modificatore(dove, {"bersaglio": {"tipo": "carta"}, "proprieta": e.get("proprieta", ""),
			"operazione": e.get("operazione", "somma"), "durata": e.get("durata", "turno")})


func _modificatore(dove: String, m: Dictionary) -> void:
	if not (str(m.get("proprieta", "")) in PROPRIETA):
		avvisi.append("%s: proprietà del modificatore non usata dal motore '%s'" % [dove, m.get("proprieta", "")])
	if not (str(m.get("operazione", "somma")) in Modificatore.OPERAZIONI):
		errori.append("%s: operazione sconosciuta '%s'" % [dove, m.get("operazione", "")])
	if not (str(m.get("durata", "combattimento")) in Modificatore.DURATE):
		errori.append("%s: durata sconosciuta '%s'" % [dove, m.get("durata", "")])
	for chiave in m.get("bersaglio", {}).get("filtro", {}):
		if not (str(chiave) in FILTRI):
			errori.append("%s: filtro sconosciuto '%s'" % [dove, chiave])


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
