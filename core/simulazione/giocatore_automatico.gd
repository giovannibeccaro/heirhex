class_name GiocatoreAutomatico
extends RefCounted
## Strategie per le simulazioni di bilanciamento (non è un'IA da giocare).
## - PRUDENTE: se un'intenzione visibile farà danni a te o alla casa oltre il blocco, blocca tutto;
##   poi la carta che fa più danni, sul nemico con meno vita; poi il resto.
## - AGGRESSIVA: non si difende mai prima di attaccare.
## - RAGIONEVOLE: prima le carte che preparano (pesca, stati su di sé); si difende solo se il colpo
##   annunciato supera una quota della vita massima (SOGLIA_DIFESA) o sarebbe letale, e blocca solo
##   finché il danno resta sopra la soglia; se con la mano può uccidere il nemico, attacca subito.

enum Strategia { PRUDENTE, RAGIONEVOLE, AGGRESSIVA }

const MASSIMO_GIOCATE_PER_TURNO := 50
## Strategia ragionevole: un colpo sotto questa quota della vita massima si incassa.
const SOGLIA_DIFESA := 0.15


static func gioca_combattimento(c: Combattimento, massimo_turni: int = 50, strategia: Strategia = Strategia.PRUDENTE) -> void:
	c.inizia()
	while not c.finito() and c.stato.turno <= massimo_turni:
		gioca_turno(c, strategia)
		c.termina_turno()


static func gioca_turno(c: Combattimento, strategia: Strategia = Strategia.PRUDENTE) -> void:
	for i in MASSIMO_GIOCATE_PER_TURNO:
		if c.finito():
			return
		var mossa := scegli_mossa(c, strategia)
		if mossa.is_empty() or not c.gioca_carta(int(mossa["carta"]), mossa["scelte"]):
			return


## { carta: uid, scelte: {...} } oppure {} se non c'è niente da giocare.
static func scegli_mossa(c: Combattimento, strategia: Strategia = Strategia.PRUDENTE) -> Dictionary:
	var s := c.stato
	var giocabili: Array[Carta] = []
	for carta in s.mano:
		if carta.giocabile() and c.costo_carta(carta) <= s.energia:
			giocabili.append(carta)
	if giocabili.is_empty():
		return {}
	var bersaglio := _nemico_piu_debole(c)
	var scelte := {Id.NEMICO: bersaglio.uid} if bersaglio != null else {}
	var ragionevole := strategia == Strategia.RAGIONEVOLE

	# 0. Ragionevole: prima le carte che preparano (pesca, stati su di sé), se non attaccano né bloccano
	if ragionevole:
		for carta in giocabili:
			if _prepara(carta):
				return {"carta": carta.uid, "scelte": scelte}

	# 1. Difesa contro gli attacchi annunciati
	if strategia != Strategia.AGGRESSIVA and not (ragionevole and _puo_uccidere(c, giocabili, bersaglio)):
		var chi := _da_difendere(c, ragionevole)
		if chi != &"":
			var migliore := _migliore(c, giocabili, Id.BLOCCO, chi)
			if migliore != null:
				var d := scelte.duplicate()
				d[Id.SE_O_CASA] = chi
				return {"carta": migliore.uid, "scelte": d}

	# 2. Attacco
	var attacco := _migliore(c, giocabili, Id.DANNO, Id.SE)
	if attacco != null:
		return {"carta": attacco.uid, "scelte": scelte}

	# 3. Il resto (pesca, cure, stati…); il blocco va dove serve di più
	var altra := giocabili[0]
	var d := scelte.duplicate()
	d[Id.SE_O_CASA] = Id.CASA if s.casa.quota_vita() < s.giocatore.quota_vita() else Id.SE
	return {"carta": altra.uid, "scelte": d}


## Chi difendere (Id.SE, Id.CASA) oppure &"" se non serve.
## Prudente: qualsiasi danno oltre il blocco. Ragionevole: danno sopra la soglia o letale.
static func _da_difendere(c: Combattimento, ragionevole: bool) -> StringName:
	var s := c.stato
	for coppia in [[Id.SE, s.giocatore], [Id.CASA, s.casa]]:
		var chi: Combattente = coppia[1]
		var netto := danno_in_arrivo(c, chi) - chi.blocco
		if netto <= 0:
			continue
		if not ragionevole or netto >= chi.vita or netto >= SOGLIA_DIFESA * chi.vita_max:
			return coppia[0]
	return &""


## Carte che preparano: nessun danno né blocco, ma pesca o uno stato su di sé.
static func _prepara(carta: Carta) -> bool:
	var prepara := false
	for e in carta.effetti():
		var tipo := StringName(e.get("tipo", ""))
		if tipo == Id.DANNO or tipo == Id.BLOCCO:
			return false
		if tipo == Id.PESCA or (tipo == Id.APPLICA_STATO and StringName(e.get("bersaglio", Id.SE)) == Id.SE):
			prepara = true
	return prepara


## Con l'energia di adesso, le carte d'attacco in mano bastano a uccidere il bersaglio?
static func _puo_uccidere(c: Combattimento, carte: Array[Carta], bersaglio: Nemico) -> bool:
	if bersaglio == null:
		return false
	var attacchi := carte.filter(func(x: Carta) -> bool: return valore_della_carta(c, x, Id.DANNO, Id.SE) > 0)
	attacchi.sort_custom(func(a: Carta, b: Carta) -> bool:
		return valore_della_carta(c, a, Id.DANNO, Id.SE) * maxi(1, c.costo_carta(b)) > valore_della_carta(c, b, Id.DANNO, Id.SE) * maxi(1, c.costo_carta(a)))
	var energia := c.stato.energia
	var danno := 0
	for carta: Carta in attacchi:
		var costo := c.costo_carta(carta)
		if costo <= energia:
			energia -= costo
			danno += valore_della_carta(c, carta, Id.DANNO, Id.SE)
	return danno >= bersaglio.vita + bersaglio.blocco


## Danno che le intenzioni visibili faranno a questo bersaglio nel prossimo turno dei nemici.
static func danno_in_arrivo(c: Combattimento, bersaglio: Combattente) -> int:
	var totale := 0
	for n in c.stato.nemici_vivi():
		if n.intenzione_annullata:
			continue
		for e in n.intenzione.get("effetti", []):
			if StringName(e.get("tipo", "")) != Id.DANNO:
				continue
			var colpisce_casa := StringName(e.get("bersaglio", Id.GIOCATORE)) == Id.CASA
			if colpisce_casa != (bersaglio == c.stato.casa):
				continue
			if bool(e.get("letale", false)):
				totale += bersaglio.vita + bersaglio.blocco
			else:
				totale += c.valore_effetto(e, ContestoEffetto.new(n), bersaglio)
	return totale


## La carta con il valore più alto per un tipo di effetto (danno o blocco); null se nessuna ne ha.
static func _migliore(c: Combattimento, carte: Array[Carta], tipo: StringName, se_o_casa: StringName) -> Carta:
	var migliore: Carta = null
	var valore_migliore := 0
	for carta in carte:
		var v := valore_della_carta(c, carta, tipo, se_o_casa)
		if v > valore_migliore:
			migliore = carta
			valore_migliore = v
	return migliore


static func valore_della_carta(c: Combattimento, carta: Carta, tipo: StringName, se_o_casa: StringName) -> int:
	var totale := 0
	var ctx := ContestoEffetto.new(c.stato.giocatore, carta)
	for e in carta.effetti():
		if StringName(e.get("tipo", "")) != tipo:
			continue
		var b := StringName(e.get("bersaglio", Id.SE))
		if tipo == Id.BLOCCO and not (b == Id.SE_O_CASA or b == se_o_casa):
			continue
		var v := c.valore_effetto(e, ctx)
		if b == Id.TUTTI_NEMICI:
			v *= c.stato.nemici_vivi().size()
		totale += v
	return totale


static func _nemico_piu_debole(c: Combattimento) -> Nemico:
	var scelto: Nemico = null
	for n in c.stato.nemici_vivi():
		if scelto == null or n.vita < scelto.vita:
			scelto = n
	return scelto
