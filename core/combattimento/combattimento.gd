class_name Combattimento
extends RefCounted
## Il combattimento: crea lo stato e applica le regole del turno.
## L'interfaccia (o una simulazione) chiama solo i metodi pubblici: inizia, gioca_carta, termina_turno.

enum Esito { IN_CORSO, VITTORIA, SCONFITTA }

var stato: StatoCombattimento
var registro := Registro.new()
var eventi := EventiGioco.new()
var _vita_iniziale: int = 0
var esito: Esito = Esito.IN_CORSO


## impostazioni:
##   seme: int
##   mazzo: Array di id oppure { id, ereditata, livello }
##   nemici: Array di id oppure { id, forma, quota_vita, intenzioni_fase }
##   giocatore: { vita, vita_max, stati }
##   casa: { vita, vita_max }
##   mano: carte pescate a inizio turno (età)
##   modificatori: Array di modificatori (dizionari) attivi in questo combattimento
##   agganci: Array di { quando, effetti } eseguiti dal giocatore (lasciti, amuleti…)
func _init(catalogo: Catalogo, impostazioni: Dictionary, regole: RegoleCombattimento = null) -> void:
	var casuale := Casuale.new(int(impostazioni.get("seme", 0)))
	stato = StatoCombattimento.new(catalogo, casuale, regole)
	_prepara_giocatore(impostazioni.get("giocatore", {}))
	_prepara_casa(impostazioni.get("casa", {}))
	_vita_iniziale = stato.giocatore.vita
	stato.mano_dimensione = int(impostazioni.get("mano", 5))
	for m in impostazioni.get("modificatori", []):
		stato.modificatori.aggiungi_da_dizionario(m)
	stato.agganci = impostazioni.get("agganci", []).duplicate()
	for voce in impostazioni.get("mazzo", []):
		stato.mazzo.append(_crea_carta(voce))
	for voce in impostazioni.get("nemici", []):
		stato.nemici.append(_crea_nemico(voce))
	stato.casuale.mescola(stato.mazzo)


## Forma della fattura: moltiplicatori di vita e danno (bilanciamento) come modificatori,
## più le intenzioni aggiunte dal nemico (le forme sono cumulative: divorata include toccata).
func _applica_forma(n: Nemico, forma: StringName) -> void:
	assert(forma in Id.FORME, "Forma sconosciuta: " + forma)
	n.forma = forma
	if forma == Id.BASE:
		return
	var moltiplicatori: Dictionary = stato.catalogo.bilanciamento.get("forme", {}).get(forma, {})
	# Nel bilanciamento: "vita" moltiplica la vita massima, "danno" i valori delle intenzioni
	for coppia in [[Id.VITA_MAX, "vita"], [Id.VALORE_EFFETTI, "danno"]]:
		if moltiplicatori.has(coppia[1]):
			stato.modificatori.aggiungi(Modificatore.crea(Id.NEMICO, coppia[0], Id.MOLTIPLICA,
				float(moltiplicatori[coppia[1]]), Id.COMBATTIMENTO, {Id.UID: n.uid}, "forma." + forma))
	n.vita_max = roundi(calcola(n.vita_max, Id.VITA_MAX, Id.NEMICO, n))
	n.vita = n.vita_max
	var forme_dati: Dictionary = n.dati.get("forme", {})
	if moltiplicatori.has("intenzione_potenziata"):
		_potenzia_intenzioni(n, forme_dati.get(forma, {}), float(moltiplicatori["intenzione_potenziata"]))
	for nome_forma in Id.FORME:
		n.intenzioni_base.append_array(forme_dati.get(nome_forma, {}).get("intenzioni_aggiunte", []))
		if nome_forma == forma:
			break


## D60: nella forma divorata un'intenzione ha i valori in punti moltiplicati (oltre ai moltiplicatori globali).
## Quali: "intenzioni_potenziate" nei dati del nemico; se mancano, la sua intenzione con più danno.
## Il valore resta decimale: si arrotonda una volta sola, con i modificatori (valore_effetto).
func _potenzia_intenzioni(n: Nemico, dati_forma: Dictionary, moltiplicatore: float) -> void:
	var ids: Array = dati_forma.get("intenzioni_potenziate", [])
	if ids.is_empty():
		var piu_forte := IntelligenzaNemici.intenzione_piu_dannosa(n.dati.get("intenzioni", []))
		if not piu_forte.is_empty():
			ids = [piu_forte["id"]]
	for i in n.intenzioni_base.size():
		var intenzione: Dictionary = n.intenzioni_base[i]
		if not ids.has(intenzione.get("id")):
			continue
		var copia := intenzione.duplicate(true)
		for e: Dictionary in copia.get("effetti", []):
			if StringName(e.get("tipo", "")) in Id.EFFETTI_IN_PUNTI and e.has("valore"):
				e["valore"] = float(e["valore"]) * moltiplicatore
		copia["potenziata"] = true
		n.intenzioni_base[i] = copia
		registro.aggiungi(0, Id.R_INTENZIONE_POTENZIATA, {"nemico": nome_tecnico(n), "intenzione": copia["id"], "moltiplicatore": moltiplicatore})


func _prepara_giocatore(d: Dictionary) -> void:
	var vita_max := int(d.get("vita_max", d.get("vita", 100)))
	stato.giocatore = Combattente.new(Id.GIOCATORE, vita_max, "combattimento.giocatore")
	stato.giocatore.vita = int(d.get("vita", vita_max))
	stato.giocatore.stati = (d.get("stati", {}) as Dictionary).duplicate()


## La casa c'è sempre (D59); senza valori prende la vita dal bilanciamento.
func _prepara_casa(d: Dictionary) -> void:
	var predefinita := int(stato.catalogo.bilanciamento.get("casa", {}).get("vita", 1))
	var vita_max := int(d.get("vita_max", d.get("vita", predefinita)))
	stato.casa = Casa.new(vita_max)
	stato.casa.vita = int(d.get("vita", vita_max))


func _crea_carta(voce: Variant) -> Carta:
	if voce is Dictionary:
		return stato.nuova_carta(str(voce["id"]), bool(voce.get("ereditata", false)), int(voce.get("livello", 0)))
	return stato.nuova_carta(str(voce))


func _crea_nemico(voce: Variant) -> Nemico:
	var d: Dictionary = voce if voce is Dictionary else {"id": str(voce)}
	var n := stato.nuovo_nemico(str(d["id"]))
	_applica_forma(n, StringName(d.get("forma", Id.BASE)))
	# Intenzioni generate da fuori (es. carte rubate dal Tiranno) per l'ultima fase
	if d.has("intenzioni_fase") and not n.fasi.is_empty():
		var ultima: Dictionary = n.fasi.back()
		var intenzioni: Array = ultima.get("intenzioni", []).duplicate()
		intenzioni.append_array(d["intenzioni_fase"])
		ultima["intenzioni"] = intenzioni
	if d.has("quota_vita"):
		n.vita = maxi(1, roundi(n.vita_max * float(d["quota_vita"])))
	return n


# === Azioni pubbliche ==========================================================

## Avvia il combattimento: i nemici mostrano l'intenzione e inizia il primo turno.
func inizia() -> void:
	registro.aggiungi(0, Id.INIZIO_COMBATTIMENTO, {"nemici": stato.nemici.map(func(n: Nemico) -> String: return n.id)})
	emetti(Id.INIZIO_COMBATTIMENTO, {"chi": stato.giocatore})
	for n in stato.nemici.duplicate():
		emetti(Id.INIZIO_COMBATTIMENTO, {"chi": n})
	if finito():
		return
	for n in stato.nemici_vivi():
		_rivela_intenzione(n, 1)
	_inizia_turno_giocatore()


## Gioca una carta dalla mano. scelte: { nemico: uid, se_o_casa: "se"|"casa", ... }.
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
	if _serve_nemico(carta) and scelte.has(Id.NEMICO):
		var scelto := stato.nemico_per_uid(int(scelte[Id.NEMICO]))
		if scelto == null or not scelto.e_vivo():
			return false
	stato.energia -= costo
	stato.mano.erase(carta)
	registro.aggiungi(stato.turno, Id.CARTA_GIOCATA, {"carta": carta.id, "uid": carta.uid, "costo": costo})
	var ctx := ContestoEffetto.new(stato.giocatore, carta, scelte)
	Mattoncini.esegui_lista(self, carta.effetti(), ctx)
	if ctx.esilia_carta or carta.esilia_dopo_uso():
		stato.esilio.append(carta)
	else:
		stato.scarti.append(carta)
	stato.giocate[carta.uid] = int(stato.giocate.get(carta.uid, 0)) + 1
	emetti(Id.CARTA_GIOCATA, {"chi": stato.giocatore, "carta": carta})
	return true


## Fine del turno del giocatore: scarta la mano, turno dei nemici, nuovo turno.
func termina_turno() -> void:
	if finito():
		return
	registro.aggiungi(stato.turno, Id.FINE_TURNO, {"chi": Id.GIOCATORE})
	emetti(Id.FINE_TURNO, {"chi": stato.giocatore})
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


## L'esito come testo tecnico ("in_corso", "vittoria", "sconfitta"), per registro e riepilogo.
func nome_esito() -> String:
	return Esito.keys()[esito].to_lower()


## Cosa serve alla vita dopo il combattimento (e agli snapshot).
func riepilogo() -> Dictionary:
	var g := stato.giocatore
	var persistenti := {}
	for id_stato in g.stati:
		if bool(stato.catalogo.stato(id_stato).get("persistente", false)):
			persistenti[id_stato] = g.stati[id_stato]
	var giocate_per_carta := {}
	for carta in stato.tutte_le_carte():
		var volte := int(stato.giocate.get(carta.uid, 0))
		if volte > 0:
			giocate_per_carta[carta.id] = int(giocate_per_carta.get(carta.id, 0)) + volte
	return {
		"esito": nome_esito(),
		"turni": stato.turno,
		"vita": g.vita,
		"vita_max": g.vita_max,
		"vita_iniziale": _vita_iniziale,
		"vita_persa": _vita_iniziale - g.vita,
		"stati_persistenti": persistenti,
		"casa_vita": stato.casa.vita,
		"tratti_negativi": stato.casa.tratti_negativi,
		"giocate": stato.giocate.duplicate(),
		"giocate_per_carta": giocate_per_carta,
		"carte_rubate": stato.rubate.map(func(x: Carta) -> String: return x.id),
		"nemici": stato.nemici.map(func(n: Nemico) -> Dictionary: return {"id": n.id, "vita": n.vita, "vita_max": n.vita_max, "quota_vita": n.quota_vita()}),
	}


# === Valori calcolati (li usa anche l'interfaccia) =============================

func costo_carta(carta: Carta) -> int:
	return maxi(0, roundi(calcola(carta.costo_base(), Id.COSTO, Id.CARTA, carta)))


## Calcola una proprietà con tutti i modificatori attivi (anche quelli degli stati).
func calcola(base: float, proprieta: StringName, tipo_oggetto: StringName, oggetto: Variant) -> float:
	return stato.modificatori.calcola(base, proprieta, tipo_oggetto, oggetto, modificatori_extra())


## Modificatori che non stanno nella lista ma nascono dallo stato (es. gli stati con cariche).
func modificatori_extra() -> Array[Modificatore]:
	return GestoreStati.modificatori(self)


## Emette un evento di gioco: reagiscono gli stati, i modificatori a tempo, gli agganci esterni,
## poi chi si è registrato con eventi.ascolta().
func emetti(evento: StringName, dati: Dictionary) -> void:
	GestoreStati.reagisci(self, evento, dati)
	var chi: Variant = dati.get("chi")
	if evento == Id.FINE_TURNO and chi == stato.giocatore:
		stato.modificatori.scadenza(Id.TURNO)
	elif evento == Id.FINE_COMBATTIMENTO:
		stato.modificatori.scadenza(Id.COMBATTIMENTO)
	if chi == null or chi == stato.giocatore:
		for aggancio in stato.agganci:
			if StringName(aggancio.get("quando", "")) == evento and not finito():
				Mattoncini.esegui_lista(self, aggancio.get("effetti", []), ContestoEffetto.new(stato.giocatore))
	eventi.emetti(evento, dati)


## Valore finale di un effetto (percentuale, modificatori della fonte e del bersaglio).
func valore_effetto(effetto: Dictionary, ctx: ContestoEffetto, bersaglio: Combattente = null) -> int:
	var tipo := StringName(effetto.get("tipo", ""))
	var base := float(effetto.get("valore", 0))
	if bool(effetto.get("percentuale", false)) and bersaglio != null:
		base = bersaglio.vita_max * base / 100.0
	if tipo in Id.EFFETTI_IN_PUNTI and not bool(effetto.get("percentuale", false)):
		if ctx.carta != null:
			base = calcola(base, Id.VALORE_EFFETTI, Id.CARTA, ctx.carta)
		elif ctx.sorgente is Nemico:
			base = calcola(base, Id.VALORE_EFFETTI, Id.NEMICO, ctx.sorgente)
	if tipo == Id.DANNO and bersaglio != null:
		base = calcola(base, Id.DANNO_SUBITO, tipo_di(bersaglio), bersaglio)
	return maxi(0, roundi(base))


## Tipo di bersaglio dei modificatori per un combattente.
func tipo_di(c: Combattente) -> StringName:
	if c is Nemico:
		return Id.NEMICO
	if c == stato.casa:
		return Id.CASA
	return Id.GIOCATORE


## Il nemico scelto dal giocatore; se manca la scelta, il primo vivo.
func nemico_scelto(scelte: Dictionary) -> Nemico:
	if scelte.has(Id.NEMICO):
		var n := stato.nemico_per_uid(int(scelte[Id.NEMICO]))
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
		registro.aggiungi(stato.turno, Id.PESCA, {"carte": pescate})
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
	registro.aggiungi(stato.turno, Id.DANNO, {"da": nome_tecnico(sorgente), "a": nome_tecnico(bersaglio),
		"valore": valore, "assorbito": assorbito, "subito": subito, "vita": bersaglio.vita})
	if bersaglio.vita <= 0:
		_a_zero(bersaglio)


func cura(bersaglio: Combattente, valore: int) -> void:
	if not bersaglio.e_vivo() or valore <= 0:
		return
	var curata := mini(valore, bersaglio.vita_max - bersaglio.vita)
	bersaglio.vita += curata
	registro.aggiungi(stato.turno, Id.CURA, {"a": nome_tecnico(bersaglio), "valore": valore, "curata": curata, "vita": bersaglio.vita})


func applica_stato(bersaglio: Combattente, id_stato: StringName, cariche: int) -> void:
	if cariche <= 0 or not bersaglio.e_vivo():
		return
	bersaglio.stati[id_stato] = bersaglio.cariche(id_stato) + cariche
	registro.aggiungi(stato.turno, Id.R_STATO_APPLICATO, {"a": nome_tecnico(bersaglio), "stato": id_stato, "cariche": cariche, "totale": bersaglio.cariche(id_stato)})
	GestoreStati.controlla_soglia(self, bersaglio, id_stato)


## Toglie cariche di uno stato; quante < 0 = tutte.
func rimuovi_stato(bersaglio: Combattente, id_stato: StringName, quante: int) -> void:
	var prima := bersaglio.cariche(id_stato)
	if prima <= 0:
		return
	var dopo := 0 if quante < 0 else maxi(0, prima - quante)
	if dopo == 0:
		bersaglio.stati.erase(id_stato)
	else:
		bersaglio.stati[id_stato] = dopo
	registro.aggiungi(stato.turno, Id.R_STATO_RIMOSSO, {"a": nome_tecnico(bersaglio), "stato": id_stato, "tolte": prima - dopo, "totale": dopo})


func annulla_intenzione(n: Nemico) -> void:
	if n.intenzione.is_empty() or bool(n.intenzione.get("non_annullabile", false)):
		registro.aggiungi(stato.turno, Id.R_ANNULLAMENTO_FALLITO, {"nemico": nome_tecnico(n)})
		return
	n.intenzione_annullata = true
	registro.aggiungi(stato.turno, Id.R_INTENZIONE_ANNULLATA, {"nemico": nome_tecnico(n), "intenzione": n.intenzione.get("id", "")})


## Fa entrare un nuovo nemico (rispetta il limite di nemici in campo). Restituisce il nemico o null.
func evoca(id_nemico: StringName) -> Nemico:
	if stato.nemici_vivi().size() >= stato.regole.nemici_max:
		registro.aggiungi(stato.turno, Id.R_EVOCAZIONE_FALLITA, {"nemico": id_nemico})
		return null
	var n := stato.nuovo_nemico(id_nemico)
	stato.nemici.append(n)
	registro.aggiungi(stato.turno, Id.R_EVOCATO, {"nemico": nome_tecnico(n)})
	_rivela_intenzione(n, stato.turno + 1)
	return n


func aggiungi_blocco(bersaglio: Combattente, valore: int) -> void:
	if valore <= 0:
		return
	bersaglio.blocco += valore
	registro.aggiungi(stato.turno, Id.BLOCCO, {"a": nome_tecnico(bersaglio), "valore": valore, "totale": bersaglio.blocco})


# === Ciclo del turno ===========================================================

func _inizia_turno_giocatore() -> void:
	stato.turno += 1
	registro.aggiungi(stato.turno, Id.INIZIO_TURNO, {"chi": Id.GIOCATORE})
	_riduci_blocco(stato.giocatore)
	_riduci_blocco(stato.casa)
	stato.energia = maxi(0, roundi(calcola(stato.regole.energia_per_turno, Id.ENERGIA, Id.GIOCATORE, stato.giocatore)))
	var mano := roundi(calcola(stato.mano_dimensione, Id.MANO, Id.GIOCATORE, stato.giocatore))
	pesca(maxi(0, mano - stato.mano.size()))
	# Dopo la pesca, così gli stati che agiscono sulla mano (es. scartare) trovano le carte
	emetti(Id.INIZIO_TURNO, {"chi": stato.giocatore})


func _turno_dei_nemici() -> void:
	# Copia: i nemici evocati in questo turno agiscono dal prossimo.
	var in_campo := stato.nemici.duplicate()
	for n: Nemico in in_campo:
		if not n.e_vivo():
			continue
		_riduci_blocco(n)
		emetti(Id.INIZIO_TURNO, {"chi": n})
		if finito():
			return
		if not n.e_vivo():
			continue
		if n.intenzione_annullata:
			n.intenzione_annullata = false
			registro.aggiungi(stato.turno, Id.R_INTENZIONE_SALTATA, {"nemico": nome_tecnico(n)})
		elif not n.intenzione.is_empty():
			registro.aggiungi(stato.turno, Id.R_INTENZIONE_ESEGUITA, {"nemico": nome_tecnico(n), "intenzione": n.intenzione.get("id", "")})
			Mattoncini.esegui_lista(self, n.intenzione.get("effetti", []), ContestoEffetto.new(n))
		if finito():
			return
		emetti(Id.FINE_TURNO, {"chi": n})
		if finito():
			return
	for n in stato.nemici_vivi():
		_rivela_intenzione(n, stato.turno + 1)


func _rivela_intenzione(n: Nemico, turno: int) -> void:
	n.intenzione = IntelligenzaNemici.scegli(n, turno, stato.casuale)
	registro.aggiungi(stato.turno, Id.R_INTENZIONE, {"nemico": nome_tecnico(n), "intenzione": n.intenzione.get("id", ""), "per_turno": turno})


## All'inizio del turno di chi lo possiede il blocco si riduce (dimezzato, arrotondato per difetto).
func _riduci_blocco(c: Combattente) -> void:
	c.blocco = floori(c.blocco * stato.regole.quota_blocco_mantenuta)


func _rimescola_scarti() -> void:
	stato.mazzo.append_array(stato.scarti)
	stato.scarti.clear()
	stato.casuale.mescola(stato.mazzo)
	registro.aggiungi(stato.turno, Id.R_RIMESCOLA, {"carte": stato.mazzo.size()})


func _a_zero(c: Combattente) -> void:
	if c == stato.giocatore:
		_termina(Esito.SCONFITTA)
	elif c == stato.casa:
		# Tratto negativo all'erede (massimo uno per combattimento), poi la casa torna a metà.
		if stato.casa.tratti_negativi == 0:
			stato.casa.tratti_negativi = 1
		stato.casa.vita = maxi(1, roundi(stato.casa.vita_max / 2.0))
		registro.aggiungi(stato.turno, Id.R_CASA_A_ZERO, {"tratti_negativi": stato.casa.tratti_negativi, "vita": stato.casa.vita})
	elif c is Nemico:
		registro.aggiungi(stato.turno, Id.R_MORTE, {"nemico": nome_tecnico(c)})
		(c as Nemico).intenzione = {}
		if stato.nemici_vivi().is_empty():
			_termina(Esito.VITTORIA)


func _termina(e: Esito) -> void:
	if finito():
		return
	esito = e
	registro.aggiungi(stato.turno, Id.FINE_COMBATTIMENTO, {"esito": nome_esito()})
	emetti(Id.FINE_COMBATTIMENTO, {"esito": nome_esito()})


func _serve_nemico(carta: Carta) -> bool:
	for e in carta.effetti():
		if StringName(e.get("bersaglio", "")) == Id.NEMICO:
			return true
	return false


## Nome tecnico per il registro (id e uid), non testo di gioco.
func nome_tecnico(c: Combattente) -> String:
	if c is Nemico:
		return "%s#%d" % [c.id, (c as Nemico).uid]
	return c.id
