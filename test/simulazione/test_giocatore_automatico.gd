extends GutTest
## T2.4 — La strategia semplice delle simulazioni.

const Aiuti := preload("res://test/aiuti.gd")


func _nuovo(extra: Dictionary) -> Combattimento:
	return Combattimento.new(Aiuti.catalogo(), Aiuti.impostazioni(extra))


func test_finisce_il_combattimento() -> void:
	var c := _nuovo({"nemici": ["lupo"]})
	GiocatoreAutomatico.gioca_combattimento(c)
	assert_true(c.finito())


func test_deterministico() -> void:
	var a := _nuovo({"nemici": ["strega"], "seme": 9})
	var b := _nuovo({"nemici": ["strega"], "seme": 9})
	GiocatoreAutomatico.gioca_combattimento(a)
	GiocatoreAutomatico.gioca_combattimento(b)
	assert_eq(a.registro.righe(), b.registro.righe())


func test_difende_se_arriva_un_attacco() -> void:
	var c := _nuovo({"nemici": ["lupo"], "mazzo": ["colpo", "riparo"], "mano": 2})
	c.inizia()
	var mossa := GiocatoreAutomatico.scegli_mossa(c)
	assert_eq(c.stato.carta_in_mano(int(mossa["carta"])).id, "riparo")
	assert_eq(mossa["scelte"]["se_o_casa"], "se")


func test_attacca_se_non_arriva_niente() -> void:
	var c := _nuovo({"nemici": ["manichino"], "mazzo": ["colpo", "riparo", "colpo_grosso"], "mano": 3})
	c.inizia()
	var mossa := GiocatoreAutomatico.scegli_mossa(c)
	assert_eq(c.stato.carta_in_mano(int(mossa["carta"])).id, "colpo_grosso")


func test_protegge_la_casa() -> void:
	var c := _nuovo({"nemici": ["strega"], "mazzo": ["riparo", "colpo"], "mano": 2, "seme": 1})
	c.inizia()
	c.stato.nemici[0].intenzione = c.stato.nemici[0].intenzioni_base[0]  # graffio alla casa
	var mossa := GiocatoreAutomatico.scegli_mossa(c)
	assert_eq(mossa["scelte"]["se_o_casa"], "casa")


func test_danno_in_arrivo() -> void:
	var c := _nuovo({"nemici": ["lupo", "lupo"]})
	c.inizia()
	assert_eq(GiocatoreAutomatico.danno_in_arrivo(c, c.stato.giocatore), 24)
	assert_eq(GiocatoreAutomatico.danno_in_arrivo(c, c.stato.casa), 0)
