extends SceneTree
## Cerca numeri che portano i nemici negli obiettivi delle forme (D65) e scrive una PROPOSTA.
## Non modifica foglio né dati: lavora su una copia in memoria del catalogo.
##   godot --headless --path . -s res://strumenti/taratura.gd [-- --combattimenti 150]
## Passi (strategia ragionevole, media su giovinezza, età adulta e vecchiaia):
## 1. forma base contro il mazzo "inizio": per ogni nemico la vita (turni → centro dell'obiettivo)
##    e un moltiplicatore dei suoi danni (vita persa → centro dell'obiettivo);
## 2. forma toccata contro il suo mazzo: moltiplicatori di vita e danno della forma;
## 3. forma divorata contro il suo mazzo: vita, danno e moltiplicatore dell'intenzione potenziata.
## Per la Janara, che colpisce solo la casa, conta solo la durata.

const USCITA := "res://docs/proposta-taratura.json"
const ETA: Array[StringName] = [Id.GIOVINEZZA, Id.ETA_ADULTA, Id.VECCHIAIA]
const STRATEGIA := GiocatoreAutomatico.Strategia.RAGIONEVOLE

var catalogo: Catalogo
var regole: RegoleCombattimento
var nemici: Array = []
var quanti: int = 150
var _danni_originali := {}   ## nemico -> { intenzione -> danno originale }
var _cache := {}


func _initialize() -> void:
	quanti = int(_argomento("--combattimenti", "150"))
	catalogo = Caricatore.new().carica()
	if catalogo == null:
		printerr("Dati non caricabili")
		quit(1)
		return
	regole = RegoleCombattimento.da_bilanciamento(catalogo.bilanciamento)
	for id in catalogo.nemici:
		if catalogo.nemici[id].get("livello") == Id.NORMALE:
			nemici.append(id)
			_danni_originali[id] = {}
			for i: Dictionary in catalogo.nemici[id]["intenzioni"]:
				for e: Dictionary in i["effetti"]:
					if e["tipo"] == Id.DANNO and not bool(e.get("letale", false)) and e.get("bersaglio") != Id.CASA:
						_danni_originali[id][i["id"]] = int(e["valore"])
	var inizio := Time.get_ticks_msec()
	var proposta := {"nemici": {}, "forme": {}}

	# 1. Forma base
	var o_base := Simulatore.obiettivi(catalogo, Id.BASE)
	var turni_obiettivo := (float(o_base["turni_min"]) + float(o_base["turni_max"])) / 2.0
	var vita_obiettivo := (float(o_base["vita_persa_min"]) + float(o_base["vita_persa_max"])) / 2.0
	for id in nemici:
		var k := 1.0
		var vita := int(catalogo.nemici[id]["vita"])
		for giro in 2:
			vita = _cerca_vita(id, k, turni_obiettivo)
			if not _danni_originali[id].is_empty():
				k = _cerca_moltiplicatore_danno(id, vita, vita_obiettivo)
		_imposta_nemico(id, vita, k)
		proposta["nemici"][id] = _voce_nemico(id, vita, k)
		var m := _misura(Id.BASE, id)
		print("base / %s: vita %d, danni × %.2f → %.2f turni, %.1f%% vita persa" % [id, vita, k, m[0], m[1] * 100])

	# 2-3. Forme: moltiplicatori globali, ricerca a coordinate
	var griglie := {
		Id.TOCCATA: {"vita": _passi(1.0, 1.6, 0.05), "danno": _passi(0.8, 1.4, 0.05)},
		Id.DIVORATA: {"vita": _passi(1.0, 2.0, 0.1), "danno": _passi(0.8, 1.6, 0.05), "intenzione_potenziata": [1.0, 1.25, 1.5]},
	}
	for forma in [Id.TOCCATA, Id.DIVORATA]:
		var f: Dictionary = catalogo.bilanciamento["forme"][forma]
		for giro in 3:
			for campo in griglie[forma]:
				var migliore: float = f[campo]
				var perdita_migliore := INF
				for valore in griglie[forma][campo]:
					f[campo] = valore
					var p := _perdita(forma)
					if p < perdita_migliore:
						perdita_migliore = p
						migliore = valore
				f[campo] = migliore
			print("%s, giro %d: %s (perdita %.3f)" % [forma, giro + 1, str(_campi(f, griglie[forma].keys())), _perdita(forma)])
		proposta["forme"][forma] = _campi(f, griglie[forma].keys())

	var file := FileAccess.open(USCITA, FileAccess.WRITE)
	file.store_string(JSON.stringify(proposta, "  ") + "\n")
	file.close()
	print("Proposta scritta in %s (%.0f s)" % [USCITA, (Time.get_ticks_msec() - inizio) / 1000.0])
	quit(0)


# --- misure --------------------------------------------------------------------------

## [turni medi, vita persa media] sulle tre età, strategia ragionevole. Con cache.
func _misura(forma: StringName, id: String) -> Array:
	var f: Dictionary = catalogo.bilanciamento["forme"][forma]
	var chiave := [forma, id, catalogo.nemici[id]["vita"], str(_danni_attuali(id)), f.get("vita"), f.get("danno"), f.get("intenzione_potenziata")]
	if _cache.has(chiave):
		return _cache[chiave]
	var mazzo := Simulatore.mazzo_riferimento(catalogo, Simulatore.fase_della_forma(catalogo, forma))
	var turni := 0.0
	var vita := 0.0
	for eta in ETA:
		var t := Simulatore.simula(catalogo, regole, mazzo, id, eta, forma, STRATEGIA, quanti)
		turni += Simulatore.media(t["turni"]) / ETA.size()
		vita += Simulatore.media(t["vita_persa"]) / ETA.size()
	_cache[chiave] = [turni, vita]
	return _cache[chiave]


## Quanto una forma è lontana dagli obiettivi, su tutti i nemici (0 = tutti dentro).
## Una piccola spinta verso il centro dell'intervallo sceglie tra soluzioni equivalenti.
func _perdita(forma: StringName) -> float:
	var o := Simulatore.obiettivi(catalogo, forma)
	var centro_t := (float(o["turni_min"]) + float(o["turni_max"])) / 2.0
	var centro_v := (float(o["vita_persa_min"]) + float(o["vita_persa_max"])) * 50.0
	var totale := 0.0
	for id in nemici:
		var m := _misura(forma, id)
		var dt := Simulatore.distanza(m[0], o["turni_min"], o["turni_max"])
		totale += dt * dt + 0.05 * pow(m[0] - centro_t, 2)
		if not _danni_originali[id].is_empty():
			var v: float = m[1] * 100.0
			var dv := Simulatore.distanza(v, o["vita_persa_min"] * 100.0, o["vita_persa_max"] * 100.0)
			totale += pow(dv / 5.0, 2) + 0.05 * pow((v - centro_v) / 5.0, 2)
	return totale


# --- ricerche per la forma base -----------------------------------------------------------

## La vita (intera) che porta i turni medi più vicino all'obiettivo (i turni crescono con la vita).
func _cerca_vita(id: String, k: float, obiettivo: float) -> int:
	var basso := 15
	var alto := 120
	_imposta_nemico(id, basso, k)
	while alto - basso > 1:
		var meta := (basso + alto) / 2
		_imposta_nemico(id, meta, k)
		if _misura(Id.BASE, id)[0] < obiettivo:
			basso = meta
		else:
			alto = meta
	_imposta_nemico(id, basso, k)
	var t_basso: float = _misura(Id.BASE, id)[0]
	_imposta_nemico(id, alto, k)
	var t_alto: float = _misura(Id.BASE, id)[0]
	return basso if absf(t_basso - obiettivo) < absf(t_alto - obiettivo) else alto


## Il moltiplicatore dei danni (a passi di 0,05) che porta la vita persa più vicino all'obiettivo.
func _cerca_moltiplicatore_danno(id: String, vita: int, obiettivo: float) -> float:
	var basso := 0.3
	var alto := 2.5
	for i in 8:
		var meta := (basso + alto) / 2.0
		_imposta_nemico(id, vita, meta)
		if _misura(Id.BASE, id)[1] < obiettivo:
			basso = meta
		else:
			alto = meta
	var migliore := 1.0
	var distanza_migliore := INF
	for candidato in [snappedf(basso, 0.05), snappedf(alto, 0.05)]:
		_imposta_nemico(id, vita, candidato)
		var d := absf(_misura(Id.BASE, id)[1] - obiettivo)
		if d < distanza_migliore:
			distanza_migliore = d
			migliore = candidato
	return migliore


# --- modifiche in memoria ---------------------------------------------------------------------

func _imposta_nemico(id: String, vita: int, k: float) -> void:
	Simulatore.applica_proposta(catalogo, {"nemici": {id: _voce_nemico(id, vita, k)}})


func _voce_nemico(id: String, vita: int, k: float) -> Dictionary:
	var intenzioni := {}
	for id_intenzione in _danni_originali[id]:
		intenzioni[id_intenzione] = {"danno": maxi(1, roundi(_danni_originali[id][id_intenzione] * k))}
	return {"vita": vita, "intenzioni": intenzioni, "moltiplicatore_danni": snappedf(k, 0.01)}


func _danni_attuali(id: String) -> Dictionary:
	var d := {}
	for i: Dictionary in catalogo.nemici[id]["intenzioni"]:
		if _danni_originali[id].has(i["id"]):
			d[i["id"]] = i["effetti"].map(func(e: Dictionary) -> Variant: return e.get("valore"))
	return d


func _campi(d: Dictionary, campi: Array) -> Dictionary:
	var r := {}
	for c in campi:
		r[c] = snappedf(float(d[c]), 0.01)
	return r


func _passi(da: float, a: float, passo: float) -> Array:
	var r := []
	var x := da
	while x <= a + 0.0001:
		r.append(snappedf(x, 0.01))
		x += passo
	return r


func _argomento(nome: String, predefinito: String) -> String:
	var argomenti := OS.get_cmdline_user_args()
	var i := argomenti.find(nome)
	return argomenti[i + 1] if i >= 0 and i + 1 < argomenti.size() else predefinito
