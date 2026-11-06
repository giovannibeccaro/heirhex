class_name Mattoncini
extends RefCounted
## Esegue i mattoncini degli effetti. Conosce i tipi di effetto (Id), mai i contenuti.
## Un effetto è un dizionario: { tipo, valore, bersaglio, ... } (schemi-dati.md, sezione Effetto).
## Funzioni statiche: il combattimento si passa a ogni chiamata (niente riferimenti circolari).


static func esegui_lista(c: Combattimento, effetti: Array, ctx: ContestoEffetto) -> void:
	for effetto in effetti:
		if c.finito():
			return
		esegui(c, effetto, ctx)


static func esegui(c: Combattimento, effetto: Dictionary, ctx: ContestoEffetto) -> void:
	var tipo := StringName(effetto.get("tipo", ""))
	match tipo:
		Id.DANNO:
			_danno(c, effetto, ctx)
		Id.BLOCCO:
			for b in bersagli(c, effetto, ctx):
				c.aggiungi_blocco(b, c.valore_effetto(effetto, ctx, b))
		Id.CURA:
			for b in bersagli(c, effetto, ctx):
				c.cura(b, c.valore_effetto(effetto, ctx, b))
		Id.PESCA:
			c.pesca(int(effetto.get("valore", 1)))
		Id.ENERGIA:
			c.stato.energia = maxi(0, c.stato.energia + int(effetto.get("valore", 1)))
		Id.APPLICA_STATO:
			for b in bersagli(c, effetto, ctx):
				c.applica_stato(b, StringName(effetto["stato"]), int(effetto.get("valore", 1)))
		Id.RIMUOVI_STATO:
			var quante: Variant = effetto.get("valore", Id.TUTTE)
			for b in bersagli(c, effetto, ctx):
				c.rimuovi_stato(b, StringName(effetto["stato"]), -1 if StringName(str(quante)) == Id.TUTTE else int(quante))
		Id.AGGIUNGI_CARTA:
			_aggiungi_carta(c, effetto)
		Id.SCARTA:
			_scarta(c, effetto, ctx)
		Id.ESILIA:
			_esilia(c, effetto, ctx)
		Id.ANNULLA_INTENZIONE:
			for b in bersagli(c, effetto, ctx):
				if b is Nemico:
					c.annulla_intenzione(b as Nemico)
		Id.RIPRENDI_DAGLI_SCARTI:
			_riprendi(c, effetto, ctx)
		Id.RUBA_CARTA:
			if ctx.sorgente is Nemico:
				_ruba(c, effetto, ctx.sorgente as Nemico)
		Id.APPLICA_MODIFICATORE:
			_applica_modificatore(c, effetto, ctx)
		Id.EVOCA:
			for i in int(effetto.get("valore", 1)):
				c.evoca(StringName(effetto["nemico"]))
		_:
			push_error("Mattoncino sconosciuto: " + tipo)


# --- Bersagli -----------------------------------------------------------------

## Risolve il campo "bersaglio" in un elenco di combattenti vivi.
## Dal punto di vista di un nemico, "nemico" e simili indicano il giocatore.
static func bersagli(c: Combattimento, effetto: Dictionary, ctx: ContestoEffetto) -> Array[Combattente]:
	var s := c.stato
	var risultato: Array[Combattente] = []
	var chiave := StringName(effetto.get("bersaglio", Id.SE))
	var dal_giocatore := not (ctx.sorgente is Nemico)
	match chiave:
		Id.SE:
			risultato.append(ctx.sorgente)
		Id.GIOCATORE:
			risultato.append(s.giocatore)
		Id.CASA:
			risultato.append(s.casa)
		Id.SE_O_CASA:
			if StringName(ctx.scelte.get(Id.SE_O_CASA, Id.SE)) == Id.CASA:
				risultato.append(s.casa)
			else:
				risultato.append(ctx.sorgente)
		Id.NEMICO:
			if dal_giocatore:
				var n := c.nemico_scelto(ctx.scelte)
				if n != null:
					risultato.append(n)
			else:
				risultato.append(s.giocatore)
		Id.TUTTI_NEMICI:
			if dal_giocatore:
				risultato.append_array(s.nemici_vivi())
			else:
				risultato.append(s.giocatore)
		Id.NEMICO_CASUALE:
			if dal_giocatore:
				var vivi := s.nemici_vivi()
				if not vivi.is_empty():
					risultato.append(vivi[s.casuale.indice(vivi.size())])
			else:
				risultato.append(s.giocatore)
		_:
			push_error("Bersaglio sconosciuto: " + chiave)
	return risultato.filter(func(b: Combattente) -> bool: return b.e_vivo())


# --- Mattoncini ---------------------------------------------------------------

static func _danno(c: Combattimento, effetto: Dictionary, ctx: ContestoEffetto) -> void:
	for b in bersagli(c, effetto, ctx):
		# "letale": toglie tutta la vita, ignora blocco e modificatori (l'ultimo rintocco)
		if bool(effetto.get("letale", false)):
			c.infliggi_danno(b, b.vita, true, ctx.sorgente)
			continue
		var valore := c.valore_effetto(effetto, ctx, b)
		c.infliggi_danno(b, valore, bool(effetto.get("ignora_blocco", false)), ctx.sorgente)


## Aggiunge copie di una carta: "dove" = mazzo (posizione casuale), mano o scarti.
static func _aggiungi_carta(c: Combattimento, effetto: Dictionary) -> void:
	var s := c.stato
	var dove := StringName(effetto.get("dove", Id.MAZZO))
	for i in int(effetto.get("valore", 1)):
		var carta := s.nuova_carta(str(effetto["carta"]))
		match dove:
			Id.MANO:
				if s.mano.size() < s.regole.mano_limite:
					s.mano.append(carta)
				else:
					s.scarti.append(carta)
			Id.SCARTI:
				s.scarti.append(carta)
			_:
				s.mazzo.insert(s.casuale.intero(0, s.mazzo.size()), carta)
		c.registro.aggiungi(s.turno, Id.R_CARTA_AGGIUNTA, {"carta": carta.id, "uid": carta.uid, "dove": dove})


## Scarta carte dalla mano: "modo" = scelta (scelte[Id.SCARTA] = [uid]) o casuale.
static func _scarta(c: Combattimento, effetto: Dictionary, ctx: ContestoEffetto) -> void:
	var s := c.stato
	var a_caso := StringName(effetto.get("modo", Id.SCELTA)) == Id.CASUALE
	for carta in _carte_scelte(s.mano, effetto, ctx, Id.SCARTA, a_caso, s.casuale):
		s.mano.erase(carta)
		s.scarti.append(carta)
		c.registro.aggiungi(s.turno, Id.R_SCARTATA, {"carta": carta.id, "uid": carta.uid})


## Esilia: bersaglio "se" = la carta giocata; "mano" = carte scelte dalla mano (scelte[Id.ESILIA]).
static func _esilia(c: Combattimento, effetto: Dictionary, ctx: ContestoEffetto) -> void:
	var s := c.stato
	if StringName(effetto.get("bersaglio", Id.SE)) == Id.SE:
		if ctx.carta != null:
			ctx.esilia_carta = true
		return
	for carta in _carte_scelte(s.mano, effetto, ctx, Id.ESILIA, false, s.casuale):
		s.mano.erase(carta)
		s.esilio.append(carta)
		c.registro.aggiungi(s.turno, Id.R_ESILIATA, {"carta": carta.id, "uid": carta.uid})


## Riprende carte dagli scarti in mano (scelte[Id.RIPRENDI]); senza scelta, l'ultima scartata.
static func _riprendi(c: Combattimento, effetto: Dictionary, ctx: ContestoEffetto) -> void:
	var s := c.stato
	var n := int(effetto.get("valore", 1))
	var carte: Array[Carta] = []
	if ctx.scelte.has(Id.RIPRENDI):
		carte = _carte_scelte(s.scarti, effetto, ctx, Id.RIPRENDI, false, s.casuale)
	else:
		for i in mini(n, s.scarti.size()):
			carte.append(s.scarti[s.scarti.size() - 1 - i])
	for carta in carte:
		if s.mano.size() >= s.regole.mano_limite:
			break
		s.scarti.erase(carta)
		s.mano.append(carta)
		c.registro.aggiungi(s.turno, Id.R_RIPRESA, {"carta": carta.id, "uid": carta.uid})


## Un nemico ruba carte a caso per il resto del combattimento.
## "da" = mano: nel turno dei nemici la mano è già scartata, quindi ruba tra le carte
## della mano appena scartata (ancora negli scarti). "da" = mazzo: dal mazzo.
static func _ruba(c: Combattimento, effetto: Dictionary, ladro: Nemico) -> void:
	var s := c.stato
	var da_mazzo := StringName(effetto.get("da", Id.MANO)) == Id.MAZZO
	for i in int(effetto.get("valore", 1)):
		var candidate: Array[Carta] = []
		if da_mazzo:
			candidate = s.mazzo.duplicate()
		elif not s.mano.is_empty():
			candidate = s.mano.duplicate()
		else:
			candidate = s.ultima_mano.filter(func(x: Carta) -> bool: return s.scarti.has(x))
		if candidate.is_empty():
			return
		var carta: Carta = candidate[s.casuale.indice(candidate.size())]
		s.mazzo.erase(carta)
		s.mano.erase(carta)
		s.scarti.erase(carta)
		s.rubate.append(carta)
		ladro.carte_rubate.append(carta.uid)
		c.registro.aggiungi(s.turno, Id.R_RUBATA, {"carta": carta.id, "uid": carta.uid, "da": c.nome_tecnico(ladro)})


## Sceglie fino a "valore" carte da una zona: dalle scelte del giocatore, a caso, o le prime.
static func _carte_scelte(zona: Array[Carta], effetto: Dictionary, ctx: ContestoEffetto, chiave: StringName, casuale: bool, rng: Casuale) -> Array[Carta]:
	var n := int(effetto.get("valore", 1))
	var risultato: Array[Carta] = []
	if casuale:
		var copia := zona.duplicate()
		rng.mescola(copia)
		for i in mini(n, copia.size()):
			risultato.append(copia[i])
		return risultato
	if ctx.scelte.has(chiave):
		for uid in ctx.scelte[chiave]:
			for carta in zona:
				if carta.uid == int(uid) and risultato.size() < n:
					risultato.append(carta)
		return risultato
	for i in mini(n, zona.size()):
		risultato.append(zona[i])
	return risultato


## Aggiunge un modificatore al sistema unico. bersaglio: Id.CARTA_PIU_COSTOSA_IN_MANO
## (la prima tra le giocabili con il costo attuale più alto) oppure un combattente.
static func _applica_modificatore(c: Combattimento, effetto: Dictionary, ctx: ContestoEffetto) -> void:
	var proprieta := StringName(effetto["proprieta"])
	var operazione := StringName(effetto.get("operazione", Id.SOMMA))
	var valore := float(effetto.get("valore", 0))
	var durata := StringName(effetto.get("durata", Id.TURNO))
	if StringName(effetto.get("bersaglio", Id.SE)) == Id.CARTA_PIU_COSTOSA_IN_MANO:
		var scelta: Carta = null
		for carta in c.stato.mano:
			if carta.giocabile() and (scelta == null or c.costo_carta(carta) > c.costo_carta(scelta)):
				scelta = carta
		if scelta == null:
			return
		c.stato.modificatori.aggiungi(Modificatore.crea(Id.CARTA, proprieta, operazione, valore, durata, {Id.UID: scelta.uid}, "effetto"))
		c.registro.aggiungi(c.stato.turno, Id.R_MODIFICATORE, {"carta": scelta.id, "uid": scelta.uid, "proprieta": proprieta, "valore": valore})
		return
	for b in bersagli(c, effetto, ctx):
		var filtro := {Id.UID: (b as Nemico).uid} if b is Nemico else {}
		c.stato.modificatori.aggiungi(Modificatore.crea(c.tipo_di(b), proprieta, operazione, valore, durata, filtro, "effetto"))
		c.registro.aggiungi(c.stato.turno, Id.R_MODIFICATORE, {"a": c.nome_tecnico(b), "proprieta": proprieta, "valore": valore})
