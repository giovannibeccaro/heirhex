extends GutTest
## T1.8 — Esito e registro: un combattimento breve completo.

const Aiuti := preload("res://test/aiuti.gd")


## Strategia minima: gioca tutte le carte d'attacco che può, poi passa.
func _gioca_fino_alla_fine(c: Combattimento, massimo_turni: int = 30) -> void:
	c.inizia()
	while not c.finito() and c.stato.turno <= massimo_turni:
		var giocata := true
		while giocata and not c.finito():
			giocata = false
			for carta in c.stato.mano.duplicate():
				if c.gioca_carta(carta.uid):
					giocata = true
					break
		c.termina_turno()


func _combattimento(seme: int = 5) -> Combattimento:
	return Combattimento.new(Aiuti.catalogo(), Aiuti.impostazioni({
		"seme": seme, "nemici": ["lupo"], "giocatore": {"vita": 100, "stati": {"fattura": 2}},
		"mazzo": ["colpo", "colpo", "colpo", "colpo", "riparo", "riparo", "riparo", "colpo_grosso"], "mano": 4}))


func test_combattimento_completo_vinto() -> void:
	var c := _combattimento()
	_gioca_fino_alla_fine(c)
	assert_eq(c.esito, Combattimento.Esito.VITTORIA)
	var r := c.riepilogo()
	assert_eq(r["esito"], "vittoria")
	assert_eq(r["nemici"][0]["vita"], 0)
	assert_between(int(r["turni"]), 2, 6)
	assert_eq(r["vita_persa"], 100 - c.stato.giocatore.vita)
	assert_eq(r["stati_persistenti"], {"fattura": 2}, "la Fattura passa alla vita")
	var giocate := 0
	for id in r["giocate_per_carta"]:
		giocate += int(r["giocate_per_carta"][id])
	assert_eq(giocate, c.registro.conta("carta_giocata"))


func test_registro_leggibile() -> void:
	var c := _combattimento()
	_gioca_fino_alla_fine(c)
	var righe := c.registro.righe()
	assert_true(righe[0].begins_with("[T0] inizio_combattimento"))
	assert_true(righe[righe.size() - 1].begins_with("[T%d] fine_combattimento esito=vittoria" % c.stato.turno), righe[righe.size() - 1])
	assert_true(Array(righe).any(func(r: String) -> bool: return r.begins_with("[T1] carta_giocata carta=")))
	assert_true(Array(righe).any(func(r: String) -> bool: return r.contains("danno da=giocatore a=lupo#1")))
	assert_true(Array(righe).any(func(r: String) -> bool: return r.contains("intenzione_eseguita nemico=lupo#1 intenzione=morso")))
	gut.p(c.registro.testo())


func test_stesso_seme_stesso_registro() -> void:
	var a := _combattimento(11)
	var b := _combattimento(11)
	_gioca_fino_alla_fine(a)
	_gioca_fino_alla_fine(b)
	assert_eq(a.registro.righe(), b.registro.righe())


func test_sconfitta_e_riepilogo() -> void:
	var c := Combattimento.new(Aiuti.catalogo(), Aiuti.impostazioni({"nemici": ["lupo"], "giocatore": {"vita": 20, "vita_max": 100}, "mazzo": ["riparo"]}))
	_gioca_fino_alla_fine(c)
	assert_eq(c.esito, Combattimento.Esito.SCONFITTA)
	var r := c.riepilogo()
	assert_eq(r["esito"], "sconfitta")
	assert_eq(r["vita"], 0)
	assert_eq(r["vita_persa"], 20)


func test_dopo_la_fine_nessuna_azione() -> void:
	var c := _combattimento()
	_gioca_fino_alla_fine(c)
	var voci := c.registro.voci.size()
	c.termina_turno()
	assert_false(c.gioca_carta(1))
	assert_eq(c.registro.voci.size(), voci)
