class_name IntelligenzaNemici
extends RefCounted
## Sceglie l'intenzione che un nemico mostrerà per il prossimo turno.
## - intenzioni con "turno": N (es. l'ultimo rintocco) sono obbligate al turno N, mai scelte altrimenti;
## - fasi: sotto una quota di vita il nemico passa alla fase successiva (se ha intenzioni);
## - comportamento "sequenza": ordine fisso; "pesato": a caso con "peso", "max_di_fila", "ricarica".


static func scegli(n: Nemico, turno: int, casuale: Casuale) -> Dictionary:
	for i in n.intenzioni_base:
		if int(i.get("turno", 0)) == turno:
			return _registra(n, i, turno)
	aggiorna_fase(n)
	var pool := n.intenzioni_attive().filter(func(i: Dictionary) -> bool: return not i.has("turno"))
	if pool.is_empty():
		return {}
	var scelta: Dictionary
	if n.comportamento_attivo() == "sequenza":
		scelta = _da_sequenza(n, pool)
	else:
		scelta = _pesata(n, pool, turno, casuale)
	return _registra(n, scelta, turno)


## Passa alla fase più avanzata la cui soglia di vita è superata (le fasi non tornano indietro).
static func aggiorna_fase(n: Nemico) -> void:
	for indice in range(n.fasi.size() - 1, n.fase - 1, -1):
		var f: Dictionary = n.fasi[indice]
		if n.quota_vita() < float(f.get("sotto_quota_vita", 0.0)) and not (f.get("intenzioni", []) as Array).is_empty():
			n.fase = indice + 1
			n.passo_sequenza = 0
			return


## Turni che mancano alla prossima intenzione a turno fisso: { intenzione, turno, mancano } oppure {}.
static func conto_alla_rovescia(n: Nemico, turno_attuale: int) -> Dictionary:
	var migliore := {}
	for i in n.intenzioni_base:
		var t := int(i.get("turno", 0))
		if t >= turno_attuale and (migliore.is_empty() or t < int(migliore["turno"])):
			migliore = {"intenzione": str(i["id"]), "turno": t, "mancano": t - turno_attuale}
	return migliore


static func _da_sequenza(n: Nemico, pool: Array) -> Dictionary:
	var sequenza := n.sequenza_attiva()
	var id_scelto := str(sequenza[n.passo_sequenza % sequenza.size()])
	n.passo_sequenza += 1
	var trovata := cerca(pool, id_scelto)
	return trovata if not trovata.is_empty() else pool[0]


static func _pesata(n: Nemico, pool: Array, turno: int, casuale: Casuale) -> Dictionary:
	var ammesse := pool.filter(func(i: Dictionary) -> bool: return _ok_fila(n, i) and _ok_ricarica(n, i, turno))
	if ammesse.is_empty():
		ammesse = pool.filter(func(i: Dictionary) -> bool: return _ok_fila(n, i))
	if ammesse.is_empty():
		ammesse = pool
	var pesi := ammesse.map(func(i: Dictionary) -> float: return float(i.get("peso", 1)))
	var indice := casuale.indice_pesato(pesi)
	return ammesse[indice if indice >= 0 else 0]


## "max_di_fila": quante volte di seguito al massimo (0 = senza limite).
static func _ok_fila(n: Nemico, i: Dictionary) -> bool:
	var massimo := int(i.get("max_di_fila", 0))
	if massimo <= 0:
		return true
	var di_fila := 0
	for k in range(n.storico.size() - 1, -1, -1):
		if n.storico[k] != str(i["id"]):
			break
		di_fila += 1
	return di_fila < massimo


## "ricarica": N = dopo averla usata al turno T torna disponibile dal turno T + N.
static func _ok_ricarica(n: Nemico, i: Dictionary, turno: int) -> bool:
	var ricarica := int(i.get("ricarica", 0))
	var id := str(i["id"])
	if ricarica <= 0 or not n.ultimo_uso.has(id):
		return true
	return turno - int(n.ultimo_uso[id]) >= ricarica


static func _registra(n: Nemico, i: Dictionary, turno: int) -> Dictionary:
	var id := str(i.get("id", ""))
	n.storico.append(id)
	n.ultimo_uso[id] = turno
	return i


static func cerca(intenzioni: Array, id: String) -> Dictionary:
	for i in intenzioni:
		if str(i["id"]) == id:
			return i
	return {}
