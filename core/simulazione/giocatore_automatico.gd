class_name GiocatoreAutomatico
extends RefCounted
## Strategia semplice per le simulazioni di bilanciamento (non è un'IA da giocare):
## 1. se un'intenzione visibile farà danni a te o alla casa oltre il blocco, gioca la carta che blocca di più;
## 2. altrimenti gioca la carta che fa più danni, sul nemico con meno vita;
## 3. poi gioca le altre carte che può pagare.

const MASSIMO_GIOCATE_PER_TURNO := 50


## difende = false: variante di riferimento che non gioca mai per difendersi prima di attaccare.
static func gioca_combattimento(c: Combattimento, massimo_turni: int = 50, difende: bool = true) -> void:
	c.inizia()
	while not c.finito() and c.stato.turno <= massimo_turni:
		gioca_turno(c, difende)
		c.termina_turno()


static func gioca_turno(c: Combattimento, difende: bool = true) -> void:
	for i in MASSIMO_GIOCATE_PER_TURNO:
		if c.finito():
			return
		var mossa := scegli_mossa(c, difende)
		if mossa.is_empty() or not c.gioca_carta(int(mossa["carta"]), mossa["scelte"]):
			return


## { carta: uid, scelte: {...} } oppure {} se non c'è niente da giocare.
static func scegli_mossa(c: Combattimento, difende: bool = true) -> Dictionary:
	var s := c.stato
	var giocabili: Array[Carta] = []
	for carta in s.mano:
		if carta.giocabile() and c.costo_carta(carta) <= s.energia:
			giocabili.append(carta)
	if giocabili.is_empty():
		return {}
	var bersaglio := _nemico_piu_debole(c)
	var scelte := {"nemico": bersaglio.uid} if bersaglio != null else {}

	# 1. Difesa contro gli attacchi annunciati
	var minaccia_se := danno_in_arrivo(c, s.giocatore) - s.giocatore.blocco
	var minaccia_casa := danno_in_arrivo(c, s.casa) - s.casa.blocco
	if difende and (minaccia_se > 0 or minaccia_casa > 0):
		var chi := "se" if minaccia_se > 0 else "casa"
		var migliore := _migliore(c, giocabili, "blocco", chi)
		if migliore != null:
			var d := scelte.duplicate()
			d["se_o_casa"] = chi
			return {"carta": migliore.uid, "scelte": d}

	# 2. Attacco
	var attacco := _migliore(c, giocabili, "danno", "se")
	if attacco != null:
		return {"carta": attacco.uid, "scelte": scelte}

	# 3. Il resto (pesca, cure, stati…); il blocco va dove serve di più
	var altra := giocabili[0]
	var d := scelte.duplicate()
	d["se_o_casa"] = "casa" if s.casa.quota_vita() < s.giocatore.quota_vita() else "se"
	return {"carta": altra.uid, "scelte": d}


## Danno che le intenzioni visibili faranno a questo bersaglio nel prossimo turno dei nemici.
static func danno_in_arrivo(c: Combattimento, bersaglio: Combattente) -> int:
	var totale := 0
	for n in c.stato.nemici_vivi():
		if n.intenzione_annullata:
			continue
		for e in n.intenzione.get("effetti", []):
			if str(e.get("tipo", "")) != "danno":
				continue
			var verso := str(e.get("bersaglio", "giocatore"))
			var colpisce_casa := verso == "casa"
			if colpisce_casa != (bersaglio == c.stato.casa):
				continue
			if bool(e.get("letale", false)):
				totale += bersaglio.vita + bersaglio.blocco
			else:
				totale += c.valore_effetto(e, ContestoEffetto.new(n), bersaglio)
	return totale


## La carta con il valore più alto per un tipo di effetto (danno o blocco); null se nessuna ne ha.
static func _migliore(c: Combattimento, carte: Array[Carta], tipo: String, se_o_casa: String) -> Carta:
	var migliore: Carta = null
	var valore_migliore := 0
	for carta in carte:
		var v := valore_della_carta(c, carta, tipo, se_o_casa)
		if v > valore_migliore:
			migliore = carta
			valore_migliore = v
	return migliore


static func valore_della_carta(c: Combattimento, carta: Carta, tipo: String, se_o_casa: String) -> int:
	var totale := 0
	var ctx := ContestoEffetto.new(c.stato.giocatore, carta)
	for e in carta.effetti():
		if str(e.get("tipo", "")) != tipo:
			continue
		var b := str(e.get("bersaglio", "se"))
		if tipo == "blocco" and not (b == "se_o_casa" or b == se_o_casa):
			continue
		var v := c.valore_effetto(e, ctx)
		if b == "tutti_nemici":
			v *= c.stato.nemici_vivi().size()
		totale += v
	return totale


static func _nemico_piu_debole(c: Combattimento) -> Nemico:
	var scelto: Nemico = null
	for n in c.stato.nemici_vivi():
		if scelto == null or n.vita < scelto.vita:
			scelto = n
	return scelto
