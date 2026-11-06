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


# --- strategie (T2.12) -------------------------------------------------------------

func test_ragionevole_incassa_un_colpo_piccolo() -> void:
	# Pugno da 5 su 100 di vita: sotto la soglia del 15%, quindi attacca invece di bloccare
	var c := _nuovo({"nemici": ["fantoccio"], "mazzo": ["colpo", "riparo"], "mano": 2})
	c.inizia()
	var mossa := GiocatoreAutomatico.scegli_mossa(c, GiocatoreAutomatico.Strategia.RAGIONEVOLE)
	assert_eq(c.stato.carta_in_mano(int(mossa["carta"])).id, "colpo")
	var prudente := GiocatoreAutomatico.scegli_mossa(c, GiocatoreAutomatico.Strategia.PRUDENTE)
	assert_eq(c.stato.carta_in_mano(int(prudente["carta"])).id, "riparo")


func test_ragionevole_si_difende_da_un_colpo_grosso() -> void:
	# Morso da 12 su 50 di vita: sopra la soglia
	var c := _nuovo({"nemici": ["lupo"], "mazzo": ["colpo", "riparo"], "mano": 2, "giocatore": {"vita": 50}})
	c.inizia()
	var mossa := GiocatoreAutomatico.scegli_mossa(c, GiocatoreAutomatico.Strategia.RAGIONEVOLE)
	assert_eq(c.stato.carta_in_mano(int(mossa["carta"])).id, "riparo")


func test_ragionevole_attacca_se_puo_uccidere() -> void:
	var c := _nuovo({"nemici": [{"id": "lupo", "quota_vita": 0.1}], "mazzo": ["colpo", "riparo"], "mano": 2, "giocatore": {"vita": 50}})
	c.inizia()
	var mossa := GiocatoreAutomatico.scegli_mossa(c, GiocatoreAutomatico.Strategia.RAGIONEVOLE)
	assert_eq(c.stato.carta_in_mano(int(mossa["carta"])).id, "colpo")


func test_ragionevole_prima_pesca() -> void:
	var c := _nuovo({"nemici": ["manichino"], "mazzo": ["colpo", "pesca_due", "colpo", "colpo"], "mano": 2, "seme": 1})
	c.inizia()
	for carta in c.stato.mazzo.duplicate():
		if carta.id == "pesca_due":
			c.stato.mazzo.erase(carta)
			c.stato.mano.append(carta)
	var mossa := GiocatoreAutomatico.scegli_mossa(c, GiocatoreAutomatico.Strategia.RAGIONEVOLE)
	assert_eq(c.stato.carta_in_mano(int(mossa["carta"])).id, "pesca_due")


func test_aggressiva_non_si_difende() -> void:
	var c := _nuovo({"nemici": ["lupo"], "mazzo": ["colpo", "riparo"], "mano": 2})
	c.inizia()
	var mossa := GiocatoreAutomatico.scegli_mossa(c, GiocatoreAutomatico.Strategia.AGGRESSIVA)
	assert_eq(c.stato.carta_in_mano(int(mossa["carta"])).id, "colpo")


# --- Simulatore ----------------------------------------------------------------------

func test_mazzo_di_riferimento_coi_dati_veri() -> void:
	var catalogo := Caricatore.new().carica()
	var mazzo := Simulatore.mazzo_riferimento(catalogo, Simulatore.fase_della_forma(catalogo, Id.DIVORATA))
	assert_gt(mazzo.size(), 10)
	for voce in mazzo:
		assert_eq(voce["ereditata"], voce["livello"] > 0)


func test_simulatore_deterministico() -> void:
	var catalogo := Caricatore.new().carica()
	var regole := RegoleCombattimento.da_bilanciamento(catalogo.bilanciamento)
	var mazzo := Simulatore.mazzo_riferimento(catalogo, "meta")
	var nemico: String = catalogo.nemici.keys()[0]
	var a := Simulatore.simula(catalogo, regole, mazzo, nemico, Id.ETA_ADULTA, Id.TOCCATA, GiocatoreAutomatico.Strategia.RAGIONEVOLE, 20)
	var b := Simulatore.simula(catalogo, regole, mazzo, nemico, Id.ETA_ADULTA, Id.TOCCATA, GiocatoreAutomatico.Strategia.RAGIONEVOLE, 20)
	assert_eq(a["turni"], b["turni"])
	assert_eq(a["turni"].size(), 20)


func test_distanza_dall_obiettivo() -> void:
	assert_eq(Simulatore.distanza(4.5, 4, 5), 0.0)
	assert_eq(Simulatore.distanza(3.0, 4, 5), -1.0)
	assert_eq(Simulatore.distanza(6.5, 4, 5), 1.5)


func test_obiettivo_di_turni_esatto_con_tolleranza() -> void:
	var catalogo := Catalogo.new()
	catalogo.bilanciamento = {"forme": {"base": {"obiettivi": {"turni_min": 4, "turni_max": 4, "vita_persa_min": 0.08, "vita_persa_max": 0.12}}}}
	var o := Simulatore.obiettivi(catalogo, Id.BASE)
	assert_eq(o["turni_min"], 3.5)
	assert_eq(o["turni_max"], 4.5)
	assert_eq(catalogo.bilanciamento["forme"]["base"]["obiettivi"]["turni_min"], 4, "i dati non cambiano")
