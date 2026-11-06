extends GutTest
## T1.1 — Stato del combattimento e determinismo del seme.

const Aiuti := preload("res://test/aiuti.gd")


func _ordine_mazzo(c: Combattimento) -> Array:
	return c.stato.mazzo.map(func(carta: Carta) -> String: return carta.id)


func test_creazione_dello_stato() -> void:
	var c := Combattimento.new(Aiuti.catalogo(), Aiuti.impostazioni())
	var s := c.stato
	assert_eq(s.giocatore.vita, 100)
	assert_eq(s.giocatore.vita_max, 100)
	assert_eq(s.giocatore.blocco, 0)
	assert_eq(s.casa.vita, 35)
	assert_eq(s.mazzo.size(), 10)
	assert_eq(s.mano.size(), 0)
	assert_eq(s.scarti.size(), 0)
	assert_eq(s.esilio.size(), 0)
	assert_eq(s.energia, 0)
	assert_eq(s.turno, 0)
	assert_eq(s.nemici.size(), 1)
	assert_eq(s.nemici[0].vita, 50)
	assert_eq(s.mano_dimensione, 5)


func test_uid_delle_carte_unici() -> void:
	var c := Combattimento.new(Aiuti.catalogo(), Aiuti.impostazioni())
	var visti := {}
	for carta in c.stato.mazzo:
		assert_false(visti.has(carta.uid), "uid ripetuto")
		visti[carta.uid] = true


func test_vita_parziale_e_stati_iniziali() -> void:
	var imp := Aiuti.impostazioni({
		"giocatore": {"vita": 40, "vita_max": 85, "stati": {"fattura": 3}},
		"nemici": [{"id": "fantoccio", "quota_vita": 0.5}],
		"mazzo": [{"id": "colpo", "ereditata": true, "livello": 1}],
	})
	var c := Combattimento.new(Aiuti.catalogo(), imp)
	assert_eq(c.stato.giocatore.vita, 40)
	assert_eq(c.stato.giocatore.vita_max, 85)
	assert_eq(c.stato.giocatore.cariche("fattura"), 3)
	assert_eq(c.stato.nemici[0].vita, 25)
	assert_true(c.stato.mazzo[0].ereditata)
	assert_eq(c.stato.mazzo[0].livello, 1)


func test_casa_sempre_presente_con_la_vita_del_bilanciamento() -> void:
	# D59: la casa c'è in tutte le età; senza impostazioni prende la vita dal bilanciamento.
	var c := Combattimento.new(Aiuti.catalogo(), Aiuti.impostazioni({"casa": {}}))
	assert_eq(c.stato.casa.vita_max, 35)
	assert_eq(c.stato.casa.vita, 35)


func test_stesso_seme_stesso_mazzo() -> void:
	var a := Combattimento.new(Aiuti.catalogo(), Aiuti.impostazioni({"seme": 7}))
	var b := Combattimento.new(Aiuti.catalogo(), Aiuti.impostazioni({"seme": 7}))
	assert_eq(_ordine_mazzo(a), _ordine_mazzo(b))


func test_semi_diversi_mazzi_diversi() -> void:
	# Con 10 carte almeno uno di questi semi deve dare un ordine diverso dal seme 1.
	var riferimento := _ordine_mazzo(Combattimento.new(Aiuti.catalogo(), Aiuti.impostazioni({"seme": 1})))
	var diversi := 0
	for seme in [2, 3, 4, 5]:
		if _ordine_mazzo(Combattimento.new(Aiuti.catalogo(), Aiuti.impostazioni({"seme": seme}))) != riferimento:
			diversi += 1
	assert_gt(diversi, 0)


func test_casuale_deterministico() -> void:
	var a := Casuale.new(123)
	var b := Casuale.new(123)
	for i in 20:
		assert_eq(a.intero(0, 1000), b.intero(0, 1000))
	var la := [1, 2, 3, 4, 5, 6]
	var lb := [1, 2, 3, 4, 5, 6]
	a.mescola(la)
	b.mescola(lb)
	assert_eq(la, lb)


func test_casuale_ripristino_dello_stato() -> void:
	var a := Casuale.new(5)
	a.intero(0, 10)
	var salvato := a.get_stato()
	var x := a.intero(0, 1000000)
	a.set_stato(salvato)
	assert_eq(a.intero(0, 1000000), x)


func test_indice_pesato() -> void:
	var a := Casuale.new(9)
	assert_eq(a.indice_pesato([0, 0, 5]), 2)
	assert_eq(a.indice_pesato([0, 0]), -1)
	var conteggi := [0, 0]
	for i in 1000:
		conteggi[a.indice_pesato([3, 1])] += 1
	# 75% contro 25%, con tolleranza
	assert_between(conteggi[0], 680, 820)
