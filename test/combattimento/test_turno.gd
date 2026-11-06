extends GutTest
## T1.2 — Ciclo del turno.

const Aiuti := preload("res://test/aiuti.gd")


func _nuovo(extra: Dictionary = {}, regole: RegoleCombattimento = null) -> Combattimento:
	var c := Combattimento.new(Aiuti.catalogo(), Aiuti.impostazioni(extra), regole)
	c.inizia()
	return c


func _prima_in_mano(c: Combattimento, id: String) -> Carta:
	for carta in c.stato.mano:
		if carta.id == id:
			return carta
	return null


func _totale_carte(c: Combattimento) -> int:
	return c.stato.tutte_le_carte().size()


func test_primo_turno() -> void:
	var c := _nuovo()
	assert_eq(c.stato.turno, 1)
	assert_eq(c.stato.energia, 3)
	assert_eq(c.stato.mano.size(), 5)
	assert_eq(c.stato.mazzo.size(), 5)
	assert_false(c.stato.nemici[0].intenzione.is_empty(), "il nemico mostra l'intenzione")


func test_mano_dipende_dall_eta() -> void:
	assert_eq(_nuovo({"mano": 4}).stato.mano.size(), 4)
	assert_eq(_nuovo({"mano": 6}).stato.mano.size(), 6)


func test_fine_turno_scarta_la_mano_e_il_nemico_agisce() -> void:
	var c := _nuovo()
	c.termina_turno()
	assert_eq(c.stato.giocatore.vita, 95, "il fantoccio colpisce per 5")
	assert_eq(c.stato.turno, 2)
	assert_eq(c.stato.scarti.size(), 5)
	assert_eq(c.stato.mano.size(), 5)
	assert_eq(c.stato.mazzo.size(), 0)


func test_rimescola_gli_scarti_quando_il_mazzo_finisce() -> void:
	var c := _nuovo()
	c.termina_turno()
	c.termina_turno()
	assert_eq(c.stato.turno, 3)
	assert_eq(c.stato.mano.size(), 5)
	assert_eq(c.stato.mazzo.size(), 5, "10 carte: 5 in mano, 5 rimescolate nel mazzo")
	assert_eq(c.stato.scarti.size(), 0)
	assert_eq(c.registro.conta("rimescola"), 1)


func test_energia_non_si_accumula() -> void:
	var c := _nuovo()
	c.termina_turno()
	assert_eq(c.stato.energia, 3)


func test_giocare_una_carta_costa_energia() -> void:
	var c := _nuovo({"mazzo": ["colpo", "colpo", "colpo", "colpo", "colpo"]})
	var carta := c.stato.mano[0]
	assert_true(c.gioca_carta(carta.uid))
	assert_eq(c.stato.energia, 2)
	assert_eq(c.stato.nemici[0].vita, 40)
	assert_true(c.stato.scarti.has(carta))
	assert_eq(c.stato.mano.size(), 4)


func test_energia_insufficiente() -> void:
	var c := _nuovo({"mazzo": ["colpo_grosso", "colpo_grosso", "colpo_grosso"]})
	assert_true(c.gioca_carta(c.stato.mano[0].uid))
	assert_false(c.gioca_carta(c.stato.mano[0].uid), "restava 1 energia, ne servono 2")
	assert_eq(c.stato.energia, 1)
	assert_eq(c.stato.mano.size(), 2)


func test_carta_non_in_mano() -> void:
	var c := _nuovo()
	assert_false(c.gioca_carta(9999))


func test_blocco_dimezzato_a_inizio_turno() -> void:
	var c := _nuovo({"nemici": ["manichino"], "mazzo": ["riparo", "riparo", "riparo", "riparo", "riparo"]})
	c.gioca_carta(c.stato.mano[0].uid)
	c.gioca_carta(c.stato.mano[0].uid, {"se_o_culla": "culla"})
	c.gioca_carta(c.stato.mano[0].uid, {"se_o_culla": "culla"})
	assert_eq(c.stato.giocatore.blocco, 7)
	assert_eq(c.stato.culla.blocco, 14)
	c.termina_turno()
	assert_eq(c.stato.giocatore.blocco, 3, "7 dimezzato per difetto")
	assert_eq(c.stato.culla.blocco, 7)
	c.termina_turno()
	assert_eq(c.stato.giocatore.blocco, 1)
	assert_eq(c.stato.culla.blocco, 3)


func test_quota_del_blocco_configurabile() -> void:
	var regole := RegoleCombattimento.new()
	regole.quota_blocco_mantenuta = 0.0
	var c := _nuovo({"nemici": ["manichino"], "mazzo": ["riparo", "riparo", "riparo", "riparo", "riparo"]}, regole)
	c.gioca_carta(c.stato.mano[0].uid)
	c.termina_turno()
	assert_eq(c.stato.giocatore.blocco, 0, "con quota 0 il blocco svanisce")


func test_il_blocco_del_nemico_si_riduce_nel_suo_turno() -> void:
	var c := _nuovo({"nemici": ["manichino"]})
	c.stato.nemici[0].blocco = 10
	c.termina_turno()
	assert_eq(c.stato.nemici[0].blocco, 5)


func test_blocco_assorbe_il_danno_del_nemico() -> void:
	var c := _nuovo({"mazzo": ["riparo", "riparo", "riparo", "riparo", "riparo"]})
	c.gioca_carta(c.stato.mano[0].uid)
	c.termina_turno()
	assert_eq(c.stato.giocatore.vita, 100, "7 blocco assorbono il pugno da 5")
	assert_eq(c.stato.giocatore.blocco, 1, "restano 2, dimezzati a 1")


func test_ciclo_di_piu_turni_conserva_le_carte() -> void:
	var c := _nuovo({"nemici": ["fantoccio", "manichino"]})
	var bersaglio := c.stato.nemici[1].uid
	for i in 6:
		var giocabile := _prima_in_mano(c, "colpo")
		if giocabile != null:
			c.gioca_carta(giocabile.uid, {"nemico": bersaglio})
		c.termina_turno()
		assert_eq(_totale_carte(c), 10)
		assert_eq(c.stato.mano.size(), 5)
		assert_eq(c.stato.energia, 3)
	assert_eq(c.stato.turno, 7)
	assert_eq(c.stato.giocatore.vita, 70, "6 pugni da 5")


func test_vittoria_quando_muoiono_tutti_i_nemici() -> void:
	var c := _nuovo({"mazzo": ["colpo_grosso", "colpo_grosso", "colpo", "colpo", "colpo", "colpo"], "mano": 6, "nemici": [{"id": "fantoccio", "quota_vita": 0.6}]})
	c.stato.energia = 99
	for carta in c.stato.mano.duplicate():
		c.gioca_carta(carta.uid)
	assert_eq(c.esito, Combattimento.Esito.VITTORIA)
	assert_false(c.gioca_carta(c.stato.mano[0].uid) if not c.stato.mano.is_empty() else false)


func test_sconfitta() -> void:
	var c := _nuovo({"giocatore": {"vita": 5, "vita_max": 100}})
	c.termina_turno()
	assert_eq(c.esito, Combattimento.Esito.SCONFITTA)
	assert_eq(c.stato.giocatore.vita, 0)
	assert_eq(c.stato.turno, 1, "nessun nuovo turno dopo la sconfitta")
