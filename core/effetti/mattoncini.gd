class_name Mattoncini
extends RefCounted
## Esegue i mattoncini degli effetti. Conosce i tipi di effetto, mai i contenuti.
## Un effetto è un dizionario: { tipo, valore, bersaglio, ... } (schemi-dati.md, sezione Effetto).
## Funzioni statiche: il combattimento si passa a ogni chiamata (niente riferimenti circolari).

## Tipi di effetto eseguibili in combattimento (il validatore controlla i dati con questo elenco).
const TIPI := ["danno", "blocco", "cura", "pesca", "energia", "applica_stato", "rimuovi_stato",
	"aggiungi_carta", "scarta", "esilia", "annulla_intenzione", "riprendi_dagli_scarti",
	"ruba_carta", "evoca", "applica_modificatore"]
## Valori ammessi per "bersaglio".
const BERSAGLI := ["se", "giocatore", "casa", "se_o_casa", "nemico", "tutti_nemici",
	"nemico_casuale", "mano", "carta_piu_costosa_in_mano"]


static func esegui_lista(c: Combattimento, effetti: Array, ctx: ContestoEffetto) -> void:
	for effetto in effetti:
		if c.finito():
			return
		esegui(c, effetto, ctx)


static func esegui(c: Combattimento, effetto: Dictionary, ctx: ContestoEffetto) -> void:
	var tipo := str(effetto.get("tipo", ""))
	match tipo:
		"danno":
			_danno(c, effetto, ctx)
		"blocco":
			_blocco(c, effetto, ctx)
		"cura":
			for b in bersagli(c, effetto, ctx):
				c.cura(b, c.valore_effetto(effetto, ctx, b))
		"pesca":
			c.pesca(int(effetto.get("valore", 1)))
		"energia":
			c.stato.energia = maxi(0, c.stato.energia + int(effetto.get("valore", 1)))
		"applica_stato":
			for b in bersagli(c, effetto, ctx):
				c.applica_stato(b, str(effetto["stato"]), int(effetto.get("valore", 1)))
		"rimuovi_stato":
			for b in bersagli(c, effetto, ctx):
				var quante: Variant = effetto.get("valore", "tutte")
				c.rimuovi_stato(b, str(effetto["stato"]), -1 if str(quante) == "tutte" else int(quante))
		"aggiungi_carta":
			_aggiungi_carta(c, effetto)
		"scarta":
			_scarta(c, effetto, ctx)
		"esilia":
			_esilia(c, effetto, ctx)
		"annulla_intenzione":
			for b in bersagli(c, effetto, ctx):
				if b is Nemico:
					c.annulla_intenzione(b as Nemico)
		"riprendi_dagli_scarti":
			_riprendi(c, effetto, ctx)
		"ruba_carta":
			if ctx.sorgente is Nemico:
				_ruba(c, effetto, ctx.sorgente as Nemico)
		"applica_modificatore":
			_applica_modificatore(c, effetto, ctx)
		"evoca":
			for i in int(effetto.get("valore", 1)):
				c.evoca(str(effetto["nemico"]))
		_:
			push_error("Mattoncino sconosciuto: " + tipo)


# --- Bersagli -----------------------------------------------------------------

## Risolve il campo "bersaglio" in un elenco di combattenti vivi.
static func bersagli(c: Combattimento, effetto: Dictionary, ctx: ContestoEffetto) -> Array[Combattente]:
	var s := c.stato
	var risultato: Array[Combattente] = []
	var chiave := str(effetto.get("bersaglio", "se"))
	var dal_giocatore := not (ctx.sorgente is Nemico)
	match chiave:
		"se":
			risultato.append(ctx.sorgente)
		"giocatore":
			risultato.append(s.giocatore)
		"casa":
			risultato.append(s.casa)
		"se_o_casa":
			var scelta := str(ctx.scelte.get("se_o_casa", "se"))
			if scelta == "casa":
				risultato.append(s.casa)
			else:
				risultato.append(ctx.sorgente)
		"nemico":
			if dal_giocatore:
				var n := c.nemico_scelto(ctx.scelte)
				if n != null:
					risultato.append(n)
			else:
				risultato.append(s.giocatore)
		"tutti_nemici":
			if dal_giocatore:
				risultato.append_array(s.nemici_vivi())
			else:
				risultato.append(s.giocatore)
		"nemico_casuale":
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


static func _blocco(c: Combattimento, effetto: Dictionary, ctx: ContestoEffetto) -> void:
	for b in bersagli(c, effetto, ctx):
		c.aggiungi_blocco(b, c.valore_effetto(effetto, ctx, b))


## Aggiunge copie di una carta: "dove" = mazzo (posizione casuale), mano o scarti.
static func _aggiungi_carta(c: Combattimento, effetto: Dictionary) -> void:
	var s := c.stato
	for i in int(effetto.get("valore", 1)):
		var carta := s.nuova_carta(str(effetto["carta"]))
		match str(effetto.get("dove", "mazzo")):
			"mano":
				if s.mano.size() < s.regole.mano_limite:
					s.mano.append(carta)
				else:
					s.scarti.append(carta)
			"scarti":
				s.scarti.append(carta)
			_:
				s.mazzo.insert(s.casuale.intero(0, s.mazzo.size()), carta)
		c.registro.aggiungi(s.turno, "carta_aggiunta", {"carta": carta.id, "uid": carta.uid, "dove": effetto.get("dove", "mazzo")})


## Scarta carte dalla mano: "modo" = scelta (scelte.scarta = [uid]) o casuale.
static func _scarta(c: Combattimento, effetto: Dictionary, ctx: ContestoEffetto) -> void:
	var s := c.stato
	var scelte := _carte_scelte(s.mano, effetto, ctx, "scarta", str(effetto.get("modo", "scelta")) == "casuale", s.casuale)
	for carta in scelte:
		s.mano.erase(carta)
		s.scarti.append(carta)
		c.registro.aggiungi(s.turno, "scartata", {"carta": carta.id, "uid": carta.uid})


## Esilia: bersaglio "se" = la carta giocata; "mano" = carte scelte dalla mano (scelte.esilia).
static func _esilia(c: Combattimento, effetto: Dictionary, ctx: ContestoEffetto) -> void:
	var s := c.stato
	if str(effetto.get("bersaglio", "se")) == "se":
		if ctx.carta != null:
			ctx.esilia_carta = true
		return
	for carta in _carte_scelte(s.mano, effetto, ctx, "esilia", false, s.casuale):
		s.mano.erase(carta)
		s.esilio.append(carta)
		c.registro.aggiungi(s.turno, "esiliata", {"carta": carta.id, "uid": carta.uid})


## Riprende carte dagli scarti in mano (scelte.riprendi); senza scelta, l'ultima scartata.
static func _riprendi(c: Combattimento, effetto: Dictionary, ctx: ContestoEffetto) -> void:
	var s := c.stato
	var n := int(effetto.get("valore", 1))
	var carte: Array[Carta] = []
	if ctx.scelte.has("riprendi"):
		carte = _carte_scelte(s.scarti, effetto, ctx, "riprendi", false, s.casuale)
	else:
		for i in mini(n, s.scarti.size()):
			carte.append(s.scarti[s.scarti.size() - 1 - i])
	for carta in carte:
		if s.mano.size() >= s.regole.mano_limite:
			break
		s.scarti.erase(carta)
		s.mano.append(carta)
		c.registro.aggiungi(s.turno, "ripresa", {"carta": carta.id, "uid": carta.uid})


## Un nemico ruba carte a caso per il resto del combattimento.
## "da" = mano: nel turno dei nemici la mano è già scartata, quindi ruba tra le carte
## della mano appena scartata (ancora negli scarti). "da" = mazzo: dal mazzo.
static func _ruba(c: Combattimento, effetto: Dictionary, ladro: Nemico) -> void:
	var s := c.stato
	var da_mazzo := str(effetto.get("da", "mano")) == "mazzo"
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
		c.registro.aggiungi(s.turno, "rubata", {"carta": carta.id, "uid": carta.uid, "da": c.nome_tecnico(ladro)})


## Sceglie fino a "valore" carte da una zona: dalle scelte del giocatore, a caso, o le prime.
static func _carte_scelte(zona: Array[Carta], effetto: Dictionary, ctx: ContestoEffetto, chiave: String, casuale: bool, rng: Casuale) -> Array[Carta]:
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


## Aggiunge un modificatore al sistema unico. bersaglio: "carta_piu_costosa_in_mano"
## (la prima tra le giocabili con il costo attuale più alto) oppure un combattente.
static func _applica_modificatore(c: Combattimento, effetto: Dictionary, ctx: ContestoEffetto) -> void:
	var d := {"fonte": "effetto", "proprieta": effetto["proprieta"], "operazione": effetto.get("operazione", "somma"),
		"valore": effetto.get("valore", 0), "durata": effetto.get("durata", "turno")}
	var chiave := str(effetto.get("bersaglio", "se"))
	if chiave == "carta_piu_costosa_in_mano":
		var scelta: Carta = null
		for carta in c.stato.mano:
			if carta.giocabile() and (scelta == null or c.costo_carta(carta) > c.costo_carta(scelta)):
				scelta = carta
		if scelta == null:
			return
		d["bersaglio"] = {"tipo": "carta", "filtro": {"uid": scelta.uid}}
		c.stato.modificatori.aggiungi_da_dizionario(d)
		c.registro.aggiungi(c.stato.turno, "modificatore", {"carta": scelta.id, "uid": scelta.uid, "proprieta": d["proprieta"], "valore": d["valore"]})
		return
	for b in bersagli(c, effetto, ctx):
		var copia := d.duplicate()
		copia["bersaglio"] = {"tipo": c.tipo_di(b), "filtro": {"uid": (b as Nemico).uid} if b is Nemico else {}}
		c.stato.modificatori.aggiungi_da_dizionario(copia)
		c.registro.aggiungi(c.stato.turno, "modificatore", {"a": c.nome_tecnico(b), "proprieta": d["proprieta"], "valore": d["valore"]})
