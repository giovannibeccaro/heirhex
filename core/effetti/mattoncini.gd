class_name Mattoncini
extends RefCounted
## Esegue i mattoncini degli effetti. Conosce i tipi di effetto, mai i contenuti.
## Un effetto è un dizionario: { tipo, valore, bersaglio, ... } (schemi-dati.md, sezione Effetto).
## Funzioni statiche: il combattimento si passa a ogni chiamata (niente riferimenti circolari).


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
		"culla":
			if s.culla.attiva:
				risultato.append(s.culla)
		"se_o_culla":
			var scelta := str(ctx.scelte.get("se_o_culla", "se"))
			if scelta == "culla" and s.culla.attiva:
				risultato.append(s.culla)
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
		var valore := c.valore_effetto(effetto, ctx, b)
		c.infliggi_danno(b, valore, bool(effetto.get("ignora_blocco", false)), ctx.sorgente)


static func _blocco(c: Combattimento, effetto: Dictionary, ctx: ContestoEffetto) -> void:
	for b in bersagli(c, effetto, ctx):
		c.aggiungi_blocco(b, c.valore_effetto(effetto, ctx, b))
