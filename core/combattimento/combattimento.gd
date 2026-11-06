class_name Combattimento
extends RefCounted
## Il combattimento: crea lo stato e applica le regole del turno.
## L'interfaccia (o una simulazione) chiama solo i metodi pubblici: inizia, gioca_carta, termina_turno.

enum Esito { IN_CORSO, VITTORIA, SCONFITTA }

var stato: StatoCombattimento
var registro := Registro.new()
var eventi := EventiGioco.new()
var esito: Esito = Esito.IN_CORSO


## impostazioni:
##   seme: int
##   mazzo: Array di id oppure { id, ereditata, livello }
##   nemici: Array di id oppure { id, quota_vita }
##   giocatore: { vita, vita_max, stati }
##   culla: { vita, vita_max, attiva }
##   mano: carte pescate a inizio turno (età)
##   modificatori: Array di modificatori (dizionari) attivi in questo combattimento
##   agganci: Array di { quando, effetti } eseguiti dal giocatore (lasciti, amuleti…)
func _init(catalogo: Catalogo, impostazioni: Dictionary, regole: RegoleCombattimento = null) -> void:
	var casuale := Casuale.new(int(impostazioni.get("seme", 0)))
	stato = StatoCombattimento.new(catalogo, casuale, regole)
	_prepara_giocatore(impostazioni.get("giocatore", {}))
	_prepara_culla(impostazioni.get("culla", {}))
	stato.mano_dimensione = int(impostazioni.get("mano", 5))
	for m in impostazioni.get("modificatori", []):
		stato.modificatori.aggiungi_da_dizionario(m)
	stato.agganci = impostazioni.get("agganci", []).duplicate()
	for voce in impostazioni.get("mazzo", []):
		stato.mazzo.append(_crea_carta(voce))
	for voce in impostazioni.get("nemici", []):
		stato.nemici.append(_crea_nemico(voce))
	stato.casuale.mescola(stato.mazzo)


func _prepara_giocatore(d: Dictionary) -> void:
	var vita_max := int(d.get("vita_max", d.get("vita", 100)))
	stato.giocatore = Combattente.new("giocatore", vita_max, "combattimento.giocatore")
	stato.giocatore.vita = int(d.get("vita", vita_max))
	stato.giocatore.stati = (d.get("stati", {}) as Dictionary).duplicate()


func _prepara_culla(d: Dictionary) -> void:
	var vita_max := int(d.get("vita_max", d.get("vita", 1)))
	stato.culla = Culla.new(vita_max, bool(d.get("attiva", false)))
	stato.culla.vita = int(d.get("vita", vita_max))


func _crea_carta(voce: Variant) -> Carta:
	if voce is Dictionary:
		return stato.nuova_carta(str(voce["id"]), bool(voce.get("ereditata", false)), int(voce.get("livello", 0)))
	return stato.nuova_carta(str(voce))


func _crea_nemico(voce: Variant) -> Nemico:
	var d: Dictionary = voce if voce is Dictionary else {"id": str(voce)}
	var n := stato.nuovo_nemico(str(d["id"]))
	if d.has("quota_vita"):
		n.vita = maxi(1, roundi(n.vita_max * float(d["quota_vita"])))
	return n


# === Azioni pubbliche ==========================================================

## Avvia il combattimento: i nemici mostrano l'intenzione e inizia il primo turno.
func inizia() -> void:
	registro.aggiungi(0, "inizio_combattimento", {"nemici": stato.nemici.map(func(n: Nemico) -> String: return n.id)})
	emetti(EventiGioco.INIZIO_COMBATTIMENTO, {"chi": stato.giocatore})
	for n in stato.nemici.duplicate():
		emetti(EventiGioco.INIZIO_COMBATTIMENTO, {"chi": n})
	if finito():
		return
	for n in stato.nemici_vivi():
		_rivela_intenzione(n, 1)
	_inizia_turno_giocatore()


## Gioca una carta dalla mano. scelte: { nemico: uid, se_o_culla: "se"|"culla", ... }.
## Restituisce false (senza cambiare nulla) se la carta non si può giocare.
func gioca_carta(uid: int, scelte: Dictionary = {}) -> bool:
	if finito():
		return false
	var carta := stato.carta_in_mano(uid)
	if carta == null or not carta.giocabile():
		return false
	var costo := costo_carta(carta)
	if costo > stato.energia:
		return false
	if _serve_nemico(carta) and scelte.has("nemico"):
		var scelto := stato.nemico_per_uid(int(scelte["nemico"]))
		if scelto == null or not scelto.e_vivo():
			return false
	stato.energia -= costo
	stato.mano.erase(carta)
	registro.aggiungi(stato.turno, "carta_giocata", {"carta": carta.id, "uid": carta.uid, "costo": costo})
	var ctx := ContestoEffetto.new(stato.giocatore, carta, scelte)
	Mattoncini.esegui_lista(self, carta.effetti(), ctx)
	if ctx.esilia_carta or carta.esilia_dopo_uso():
		stato.esilio.append(carta)
	else:
		stato.scarti.append(carta)
	stato.giocate[carta.uid] = int(stato.giocate.get(carta.uid, 0)) + 1
	emetti(EventiGioco.CARTA_GIOCATA, {"chi": stato.giocatore, "carta": carta})
	return true


## Fine del turno del giocatore: scarta la mano, turno dei nemici, nuovo turno.
func termina_turno() -> void:
	if finito():
		return
	registro.aggiungi(stato.turno, "fine_turno", {"chi": "giocatore"})
	emetti(EventiGioco.FINE_TURNO, {"chi": stato.giocatore})
	if finito():
		return
	stato.ultima_mano = stato.mano.duplicate()
	while not stato.mano.is_empty():
		stato.scarti.append(stato.mano.pop_front())
	_turno_dei_nemici()
	if not finito():
		_inizia_turno_giocatore()


func finito() -> bool:
	return esito != Esito.IN_CORSO


# === Valori calcolati (li usa anche l'interfaccia) =============================

## Effetti "in punti": i modificatori di valore_effetti agiscono solo su questi.
const EFFETTI_IN_PUNTI := ["danno", "blocco", "cura"]


func costo_carta(carta: Carta) -> int:
	return maxi(0, roundi(calcola(carta.costo_base(), "costo", "carta", carta)))


## Calcola una proprietà con tutti i modificatori attivi (anche quelli degli stati).
func calcola(base: float, proprieta: String, tipo_oggetto: String, oggetto: Variant) -> float:
	return stato.modificatori.calcola(base, proprieta, tipo_oggetto, oggetto, modificatori_extra())


## Modificatori che non stanno nella lista ma nascono dallo stato (es. gli stati con cariche).
func modificatori_extra() -> Array[Modificatore]:
	return GestoreStati.modificatori(self)


## Emette un evento di gioco: reagiscono gli stati, i modificatori a tempo, gli agganci esterni,
## poi chi si è registrato con eventi.ascolta().
func emetti(evento: String, dati: Dictionary) -> void:
	GestoreStati.reagisci(self, evento, dati)
	var chi: Variant = dati.get("chi")
	if evento == EventiGioco.FINE_TURNO and chi == stato.giocatore:
		stato.modificatori.scadenza("turno")
	elif evento == EventiGioco.FINE_COMBATTIMENTO:
		stato.modificatori.scadenza("combattimento")
	if chi == null or chi == stato.giocatore:
		for aggancio in stato.agganci:
			if str(aggancio.get("quando", "")) == evento and not finito():
				Mattoncini.esegui_lista(self, aggancio.get("effetti", []), ContestoEffetto.new(stato.giocatore))
	eventi.emetti(evento, dati)


## Valore finale di un effetto (percentuale, modificatori della fonte e del bersaglio).
func valore_effetto(effetto: Dictionary, ctx: ContestoEffetto, bersaglio: Combattente = null) -> int:
	var tipo := str(effetto.get("tipo", ""))
	var base := float(effetto.get("valore", 0))
	if bool(effetto.get("percentuale", false)) and bersaglio != null:
		base = bersaglio.vita_max * base / 100.0
	if tipo in EFFETTI_IN_PUNTI and not bool(effetto.get("percentuale", false)):
		if ctx.carta != null:
			base = calcola(base, "valore_effetti", "carta", ctx.carta)
		elif ctx.sorgente is Nemico:
			base = calcola(base, "valore_effetti", "nemico", ctx.sorgente)
	if tipo == "danno" and bersaglio != null:
		base = calcola(base, "danno_subito", tipo_di(bersaglio), bersaglio)
	return maxi(0, roundi(base))


## Tipo di bersaglio dei modificatori per un combattente.
func tipo_di(c: Combattente) -> String:
	if c is Nemico:
		return "nemico"
	if c == stato.culla:
		return "culla"
	return "giocatore"


## Il nemico scelto dal giocatore; se manca la scelta, il primo vivo.
func nemico_scelto(scelte: Dictionary) -> Nemico:
	if scelte.has("nemico"):
		var n := stato.nemico_per_uid(int(scelte["nemico"]))
		return n if n != null and n.e_vivo() else null
	var vivi := stato.nemici_vivi()
	return vivi[0] if not vivi.is_empty() else null


# === Operazioni elementari (usate dai mattoncini) ==============================

## Pesca n carte; rimescola gli scarti quando il mazzo finisce. Restituisce le carte pescate.
func pesca(n: int) -> int:
	var pescate := 0
	for i in n:
		if stato.mano.size() >= stato.regole.mano_limite:
			break
		if stato.mazzo.is_empty():
			if stato.scarti.is_empty():
				break
			_rimescola_scarti()
		stato.mano.append(stato.mazzo.pop_back())
		pescate += 1
	if pescate > 0:
		registro.aggiungi(stato.turno, "pesca", {"carte": pescate})
	return pescate


func infliggi_danno(bersaglio: Combattente, valore: int, ignora_blocco: bool, sorgente: Combattente) -> void:
	if not bersaglio.e_vivo() or valore <= 0:
		return
	var assorbito := 0
	if not ignora_blocco:
		assorbito = mini(bersaglio.blocco, valore)
		bersaglio.blocco -= assorbito
	var subito := mini(valore - assorbito, bersaglio.vita)
	bersaglio.vita -= subito
	registro.aggiungi(stato.turno, "danno", {"da": nome_tecnico(sorgente), "a": nome_tecnico(bersaglio),
		"valore": valore, "assorbito": assorbito, "subito": subito, "vita": bersaglio.vita})
	if bersaglio.vita <= 0:
		_a_zero(bersaglio)


func cura(bersaglio: Combattente, valore: int) -> void:
	if not bersaglio.e_vivo() or valore <= 0:
		return
	var curata := mini(valore, bersaglio.vita_max - bersaglio.vita)
	bersaglio.vita += curata
	registro.aggiungi(stato.turno, "cura", {"a": nome_tecnico(bersaglio), "valore": valore, "curata": curata, "vita": bersaglio.vita})


func applica_stato(bersaglio: Combattente, id_stato: String, cariche: int) -> void:
	if cariche <= 0 or not bersaglio.e_vivo():
		return
	bersaglio.stati[id_stato] = bersaglio.cariche(id_stato) + cariche
	registro.aggiungi(stato.turno, "stato_applicato", {"a": nome_tecnico(bersaglio), "stato": id_stato, "cariche": cariche, "totale": bersaglio.cariche(id_stato)})
	GestoreStati.controlla_soglia(self, bersaglio, id_stato)


## Toglie cariche di uno stato; quante < 0 = tutte.
func rimuovi_stato(bersaglio: Combattente, id_stato: String, quante: int) -> void:
	var prima := bersaglio.cariche(id_stato)
	if prima <= 0:
		return
	var dopo := 0 if quante < 0 else maxi(0, prima - quante)
	if dopo == 0:
		bersaglio.stati.erase(id_stato)
	else:
		bersaglio.stati[id_stato] = dopo
	registro.aggiungi(stato.turno, "stato_rimosso", {"a": nome_tecnico(bersaglio), "stato": id_stato, "tolte": prima - dopo, "totale": dopo})


func annulla_intenzione(n: Nemico) -> void:
	if n.intenzione.is_empty() or bool(n.intenzione.get("non_annullabile", false)):
		registro.aggiungi(stato.turno, "annullamento_fallito", {"nemico": nome_tecnico(n)})
		return
	n.intenzione_annullata = true
	registro.aggiungi(stato.turno, "intenzione_annullata", {"nemico": nome_tecnico(n), "intenzione": n.intenzione.get("id", "")})


## Fa entrare un nuovo nemico (rispetta il limite di nemici in campo). Restituisce il nemico o null.
func evoca(id_nemico: String) -> Nemico:
	if stato.nemici_vivi().size() >= stato.regole.nemici_max:
		registro.aggiungi(stato.turno, "evocazione_fallita", {"nemico": id_nemico})
		return null
	var n := stato.nuovo_nemico(id_nemico)
	stato.nemici.append(n)
	registro.aggiungi(stato.turno, "evocato", {"nemico": nome_tecnico(n)})
	_rivela_intenzione(n, stato.turno + 1)
	return n


func aggiungi_blocco(bersaglio: Combattente, valore: int) -> void:
	if valore <= 0:
		return
	bersaglio.blocco += valore
	registro.aggiungi(stato.turno, "blocco", {"a": nome_tecnico(bersaglio), "valore": valore, "totale": bersaglio.blocco})


# === Ciclo del turno ===========================================================

func _inizia_turno_giocatore() -> void:
	stato.turno += 1
	registro.aggiungi(stato.turno, "inizio_turno", {"chi": "giocatore"})
	_riduci_blocco(stato.giocatore)
	_riduci_blocco(stato.culla)
	stato.energia = maxi(0, roundi(calcola(stato.regole.energia_per_turno, "energia", "giocatore", stato.giocatore)))
	var mano := roundi(calcola(stato.mano_dimensione, "mano", "giocatore", stato.giocatore))
	pesca(maxi(0, mano - stato.mano.size()))
	# Dopo la pesca, così gli stati che agiscono sulla mano (es. scartare) trovano le carte
	emetti(EventiGioco.INIZIO_TURNO, {"chi": stato.giocatore})


func _turno_dei_nemici() -> void:
	# Copia: i nemici evocati in questo turno agiscono dal prossimo.
	var in_campo := stato.nemici.duplicate()
	for n: Nemico in in_campo:
		if not n.e_vivo():
			continue
		_riduci_blocco(n)
		emetti(EventiGioco.INIZIO_TURNO, {"chi": n})
		if finito():
			return
		if not n.e_vivo():
			continue
		if n.intenzione_annullata:
			n.intenzione_annullata = false
			registro.aggiungi(stato.turno, "intenzione_saltata", {"nemico": nome_tecnico(n)})
		elif not n.intenzione.is_empty():
			registro.aggiungi(stato.turno, "intenzione_eseguita", {"nemico": nome_tecnico(n), "intenzione": n.intenzione.get("id", "")})
			Mattoncini.esegui_lista(self, n.intenzione.get("effetti", []), ContestoEffetto.new(n))
		if finito():
			return
		emetti(EventiGioco.FINE_TURNO, {"chi": n})
		if finito():
			return
	for n in stato.nemici_vivi():
		_rivela_intenzione(n, stato.turno + 1)


func _rivela_intenzione(n: Nemico, turno: int) -> void:
	n.intenzione = IntelligenzaNemici.scegli(n, turno, stato.casuale)
	registro.aggiungi(stato.turno, "intenzione", {"nemico": nome_tecnico(n), "intenzione": n.intenzione.get("id", ""), "per_turno": turno})


## All'inizio del turno di chi lo possiede il blocco si riduce (dimezzato, arrotondato per difetto).
func _riduci_blocco(c: Combattente) -> void:
	c.blocco = floori(c.blocco * stato.regole.quota_blocco_mantenuta)


func _rimescola_scarti() -> void:
	stato.mazzo.append_array(stato.scarti)
	stato.scarti.clear()
	stato.casuale.mescola(stato.mazzo)
	registro.aggiungi(stato.turno, "rimescola", {"carte": stato.mazzo.size()})


func _a_zero(c: Combattente) -> void:
	if c == stato.giocatore:
		_termina(Esito.SCONFITTA)
	elif c == stato.culla:
		# Tratto negativo all'erede (massimo uno per combattimento), poi la culla torna a metà.
		if stato.culla.tratti_negativi == 0:
			stato.culla.tratti_negativi = 1
		stato.culla.vita = maxi(1, roundi(stato.culla.vita_max / 2.0))
		registro.aggiungi(stato.turno, "culla_a_zero", {"tratti_negativi": stato.culla.tratti_negativi, "vita": stato.culla.vita})
	elif c is Nemico:
		registro.aggiungi(stato.turno, "morte", {"nemico": nome_tecnico(c)})
		(c as Nemico).intenzione = {}
		if stato.nemici_vivi().is_empty():
			_termina(Esito.VITTORIA)


func _termina(e: Esito) -> void:
	if finito():
		return
	esito = e
	registro.aggiungi(stato.turno, "fine_combattimento", {"esito": Esito.keys()[e].to_lower()})
	emetti(EventiGioco.FINE_COMBATTIMENTO, {"esito": Esito.keys()[e].to_lower()})


func _serve_nemico(carta: Carta) -> bool:
	for e in carta.effetti():
		if str(e.get("bersaglio", "")) == "nemico":
			return true
	return false


## Nome tecnico per il registro (id e uid), non testo di gioco.
func nome_tecnico(c: Combattente) -> String:
	if c is Nemico:
		return "%s#%d" % [c.id, (c as Nemico).uid]
	return c.id
