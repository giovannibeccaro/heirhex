extends GutTest
## T1.5 — Sistema unico dei modificatori: ordine di calcolo e durate.

const Aiuti := preload("res://test/aiuti.gd")


func _mod(proprieta: String, operazione: String, valore: float, durata: String = "combattimento", tipo: String = "giocatore", filtro: Dictionary = {}) -> Dictionary:
	return {"fonte": "test", "bersaglio": {"tipo": tipo, "filtro": filtro}, "proprieta": proprieta,
		"operazione": operazione, "valore": valore, "durata": durata}


func _sistema(mods: Array) -> SistemaModificatori:
	var s := SistemaModificatori.new()
	for m in mods:
		s.aggiungi_da_dizionario(m)
	return s


func _calcola(s: SistemaModificatori, base: float) -> float:
	return s.calcola(base, "energia", "giocatore", null)


# --- ordine di calcolo ----------------------------------------------------------

func test_somma_prima_della_moltiplicazione_in_qualsiasi_ordine() -> void:
	var a := _sistema([_mod("energia", "moltiplica", 2), _mod("energia", "somma", 5)])
	var b := _sistema([_mod("energia", "somma", 5), _mod("energia", "moltiplica", 2)])
	assert_eq(_calcola(a, 10), 30.0, "(10 + 5) × 2")
	assert_eq(_calcola(b, 10), 30.0)


func test_imposta_vince_su_tutto() -> void:
	var s := _sistema([_mod("energia", "imposta", 7), _mod("energia", "somma", 5), _mod("energia", "moltiplica", 3)])
	assert_eq(_calcola(s, 10), 7.0)


func test_piu_imposta_vale_l_ultimo() -> void:
	var s := _sistema([_mod("energia", "imposta", 7), _mod("energia", "imposta", 2)])
	assert_eq(_calcola(s, 10), 2.0)


func test_moltiplicazioni_e_somme_si_cumulano() -> void:
	var s := _sistema([_mod("energia", "moltiplica", 1.5), _mod("energia", "somma", 1), _mod("energia", "moltiplica", 2), _mod("energia", "somma", -3)])
	assert_eq(_calcola(s, 10), 24.0, "(10 + 1 − 3) × 1,5 × 2")


func test_solo_la_proprieta_e_il_bersaglio_giusti() -> void:
	var s := _sistema([_mod("mano", "somma", 1), _mod("energia", "somma", 1, "combattimento", "culla")])
	assert_eq(_calcola(s, 3), 3.0)


func test_filtro_sulle_carte() -> void:
	var s := _sistema([_mod("costo", "somma", -1, "vita", "carta", {"ereditata": true})])
	var dati := {"id": "x", "costo": 2}
	var ereditata := Carta.new(1, dati, true)
	var nuova := Carta.new(2, dati, false)
	assert_eq(s.calcola(2, "costo", "carta", ereditata), 1.0)
	assert_eq(s.calcola(2, "costo", "carta", nuova), 2.0)


func test_filtro_sconosciuto_non_corrisponde() -> void:
	var s := _sistema([_mod("costo", "somma", -1, "vita", "carta", {"colore": "rosso"})])
	assert_eq(s.calcola(2, "costo", "carta", Carta.new(1, {"id": "x"})), 2.0)


# --- durate ---------------------------------------------------------------------

func test_durate() -> void:
	var s := _sistema([_mod("energia", "somma", 1, "turno"), _mod("energia", "somma", 10, "combattimento"),
		_mod("energia", "somma", 100, "vita"), _mod("energia", "somma", 1000, "stirpe")])
	assert_eq(_calcola(s, 0), 1111.0)
	s.scadenza("turno")
	assert_eq(_calcola(s, 0), 1110.0)
	s.scadenza("combattimento")
	assert_eq(_calcola(s, 0), 1100.0)
	s.scadenza("vita")
	assert_eq(_calcola(s, 0), 1000.0)


func test_la_fine_del_combattimento_toglie_anche_quelli_del_turno() -> void:
	var s := _sistema([_mod("energia", "somma", 1, "turno"), _mod("energia", "somma", 10, "combattimento")])
	s.scadenza("combattimento")
	assert_eq(s.lista.size(), 0)


func test_rimuovi_per_fonte() -> void:
	var s := _sistema([_mod("energia", "somma", 1)])
	var altro := _mod("energia", "somma", 5)
	altro["fonte"] = "amuleto.x"
	s.aggiungi_da_dizionario(altro)
	s.rimuovi_fonte("test")
	assert_eq(_calcola(s, 0), 5.0)


# --- nel combattimento ------------------------------------------------------------

func _combattimento(mods: Array, extra: Dictionary = {}) -> Combattimento:
	var imp := Aiuti.impostazioni(extra)
	imp["modificatori"] = mods
	var c := Combattimento.new(Aiuti.catalogo(), imp)
	c.inizia()
	return c


func test_energia_e_mano_modificate() -> void:
	var c := _combattimento([_mod("energia", "somma", 1), _mod("mano", "somma", 1)])
	assert_eq(c.stato.energia, 4)
	assert_eq(c.stato.mano.size(), 6)


func test_costo_delle_carte_ereditate_e_minimo_zero() -> void:
	var c := _combattimento([_mod("costo", "somma", -2, "vita", "carta", {"ereditata": true})],
		{"mazzo": [{"id": "colpo", "ereditata": true}, {"id": "colpo_grosso", "ereditata": true}, "colpo"]})
	for carta in c.stato.mano:
		# colpo ereditato: 1 − 2 → 0 (minimo); colpo grosso ereditato: 2 − 2 = 0; colpo nuovo: 1
		var atteso := 0 if carta.ereditata else 1
		assert_eq(c.costo_carta(carta), atteso, carta.id)


func test_valore_effetti_delle_carte() -> void:
	var c := _combattimento([_mod("valore_effetti", "moltiplica", 1.3, "vita", "carta")], {"mazzo": ["colpo"]})
	c.gioca_carta(c.stato.mano[0].uid)
	assert_eq(c.stato.nemici[0].vita, 37, "10 × 1,3 = 13")


func test_valore_effetti_non_tocca_la_pesca() -> void:
	var c := _combattimento([_mod("valore_effetti", "somma", 5, "vita", "carta")], {"mazzo": ["pesca_due", "colpo", "colpo", "colpo", "colpo"], "mano": 1})
	for carta in c.stato.mazzo.duplicate():
		if carta.id == "pesca_due":
			c.stato.mazzo.erase(carta)
			c.stato.mano.append(carta)
	var prima := c.stato.mano.size()
	c.gioca_carta(c.stato.mano.filter(func(x: Carta) -> bool: return x.id == "pesca_due")[0].uid)
	assert_eq(c.stato.mano.size(), prima - 1 + 2)


func test_danno_subito() -> void:
	var c := _combattimento([_mod("danno_subito", "moltiplica", 2)])
	c.termina_turno()
	assert_eq(c.stato.giocatore.vita, 90, "il pugno da 5 raddoppia")


func test_i_modificatori_del_turno_scadono_a_fine_turno() -> void:
	var c := _combattimento([_mod("energia", "somma", 2, "turno")], {"nemici": ["manichino"]})
	assert_eq(c.stato.energia, 5)
	c.termina_turno()
	assert_eq(c.stato.energia, 3)


func test_a_fine_combattimento_restano_vita_e_stirpe() -> void:
	var c := _combattimento([_mod("energia", "somma", 1, "combattimento"), _mod("energia", "somma", 1, "vita"), _mod("energia", "somma", 1, "stirpe")],
		{"nemici": [{"id": "fantoccio", "quota_vita": 0.1}], "mazzo": ["colpo"]})
	c.gioca_carta(c.stato.mano[0].uid)
	assert_true(c.finito())
	assert_eq(c.stato.modificatori.lista.map(func(m: Modificatore) -> String: return m.durata), ["vita", "stirpe"])
