extends GutTest
## T1.4 — I quattro stati del prototipo (data/manuali/stati.json).

const Aiuti := preload("res://test/aiuti.gd")

var c: Combattimento
var g: Combattente


func _prepara(extra: Dictionary = {}) -> void:
	var base := {"nemici": ["manichino"]}
	base.merge(extra, true)
	c = Combattimento.new(Aiuti.catalogo(), Aiuti.impostazioni(base))
	c.inizia()
	g = c.stato.giocatore


func _carte(id: String) -> Array[Carta]:
	var risultato: Array[Carta] = []
	for carta in c.stato.mano:
		if carta.id == id:
			risultato.append(carta)
	return risultato


# --- Fattura ------------------------------------------------------------------

func test_fattura_sotto_la_soglia_non_fa_nulla() -> void:
	_prepara()
	c.applica_stato(g, "fattura", 6)
	assert_eq(g.vita, 100)
	assert_eq(g.cariche("fattura"), 6)


func test_fattura_si_compie_a_7() -> void:
	_prepara({"giocatore": {"vita": 85, "vita_max": 85}})
	g.blocco = 50
	c.applica_stato(g, "fattura", 5)
	c.applica_stato(g, "fattura", 2)
	assert_eq(g.vita, 85 - 26, "30% di 85 arrotondato, ignorando il blocco")
	assert_eq(g.blocco, 50)
	assert_eq(g.cariche("fattura"), 0, "si azzera")


func test_fattura_oltre_la_soglia_si_compie_una_volta() -> void:
	_prepara()
	c.applica_stato(g, "fattura", 5)
	c.applica_stato(g, "fattura", 4)
	assert_eq(g.vita, 70)
	assert_eq(g.cariche("fattura"), 0, "le cariche in eccesso si perdono")


func test_fattura_iniziale_dalla_vita_precedente() -> void:
	_prepara({"giocatore": {"vita": 60, "vita_max": 60, "stati": {"fattura": 6}}})
	assert_eq(g.cariche("fattura"), 6)
	c.applica_stato(g, "fattura", 1)
	assert_eq(g.vita, 42)


func test_fattura_persiste_tra_i_turni() -> void:
	_prepara({"giocatore": {"vita": 100, "stati": {"fattura": 3}}})
	c.termina_turno()
	c.termina_turno()
	assert_eq(g.cariche("fattura"), 3)
	assert_true(bool(c.stato.catalogo.stato("fattura")["persistente"]))


func test_fattura_puo_uccidere() -> void:
	_prepara({"giocatore": {"vita": 20, "vita_max": 100}})
	c.applica_stato(g, "fattura", 7)
	assert_eq(c.esito, Combattimento.Esito.SCONFITTA)


# --- Paura --------------------------------------------------------------------

func test_paura_la_carta_piu_costosa_costa_1_in_piu() -> void:
	_prepara({"mazzo": ["colpo", "colpo_grosso", "colpo", "colpo", "colpo"], "giocatore": {"vita": 100, "stati": {"paura": 2}}})
	assert_eq(c.costo_carta(_carte("colpo_grosso")[0]), 3)
	for carta in _carte("colpo"):
		assert_eq(c.costo_carta(carta), 1)


func test_paura_a_parita_tocca_una_sola_carta() -> void:
	_prepara({"mazzo": ["colpo", "colpo", "colpo"], "giocatore": {"vita": 100, "stati": {"paura": 1}}})
	var costi := c.stato.mano.map(func(x: Carta) -> int: return c.costo_carta(x))
	costi.sort()
	assert_eq(costi, [1, 1, 2])


func test_paura_dura_un_turno_per_carica() -> void:
	_prepara({"mazzo": ["colpo", "colpo", "colpo"], "giocatore": {"vita": 100, "stati": {"paura": 2}}})
	c.termina_turno()
	assert_eq(g.cariche("paura"), 1)
	assert_eq(c.stato.mano.map(func(x: Carta) -> int: return c.costo_carta(x)).count(2), 1, "secondo turno ancora con paura")
	c.termina_turno()
	assert_eq(g.cariche("paura"), 0)
	assert_eq(c.stato.mano.map(func(x: Carta) -> int: return c.costo_carta(x)).count(2), 0)


func test_paura_applicata_dal_nemico_vale_dal_turno_dopo() -> void:
	_prepara({"mazzo": ["colpo", "colpo", "colpo"]})
	Mattoncini.esegui(c, {"tipo": "applica_stato", "stato": "paura", "valore": 2, "bersaglio": "giocatore"}, ContestoEffetto.new(c.stato.nemici[0]))
	assert_eq(c.stato.mano.map(func(x: Carta) -> int: return c.costo_carta(x)).count(2), 0)
	c.termina_turno()
	assert_eq(c.stato.mano.map(func(x: Carta) -> int: return c.costo_carta(x)).count(2), 1)


# --- Malocchio ----------------------------------------------------------------

func test_malocchio_scarta_una_carta_a_inizio_turno() -> void:
	_prepara({"giocatore": {"vita": 100, "stati": {"malocchio": 1}}})
	assert_eq(c.stato.mano.size(), 4)
	assert_eq(c.stato.scarti.size(), 1)
	c.termina_turno()
	assert_eq(g.cariche("malocchio"), 0)
	assert_eq(c.stato.mano.size(), 5, "al turno dopo non scarta più")


func test_malocchio_con_la_mano_vuota() -> void:
	_prepara({"mazzo": [], "giocatore": {"vita": 100, "stati": {"malocchio": 2}}})
	assert_eq(c.stato.mano.size(), 0)
	assert_false(c.finito())


func test_malocchio_e_deterministico() -> void:
	var scartate := []
	for i in 2:
		_prepara({"seme": 31, "giocatore": {"vita": 100, "stati": {"malocchio": 1}}})
		scartate.append(c.stato.scarti[0].uid)
	assert_eq(scartate[0], scartate[1])


# --- Radici -------------------------------------------------------------------

func test_radici_potenziano_solo_le_carte_ereditate() -> void:
	_prepara({"mazzo": [{"id": "colpo", "ereditata": true}, "colpo"], "nemici": ["fantoccio"], "giocatore": {"vita": 100, "stati": {"radici": 2}}})
	var ereditata: Carta = c.stato.mano.filter(func(x: Carta) -> bool: return x.ereditata)[0]
	var nuova: Carta = c.stato.mano.filter(func(x: Carta) -> bool: return not x.ereditata)[0]
	c.gioca_carta(ereditata.uid)
	assert_eq(c.stato.nemici[0].vita, 50 - 14, "10 + 2 × 2")
	c.gioca_carta(nuova.uid)
	assert_eq(c.stato.nemici[0].vita, 36 - 10)


func test_radici_su_blocco_ma_non_sulla_pesca() -> void:
	_prepara({"mazzo": [{"id": "riparo", "ereditata": true}], "giocatore": {"vita": 100, "stati": {"radici": 1}}})
	c.gioca_carta(c.stato.mano[0].uid)
	assert_eq(g.blocco, 9)


func test_radici_si_sommano() -> void:
	_prepara()
	c.applica_stato(g, "radici", 1)
	c.applica_stato(g, "radici", 2)
	assert_eq(g.cariche("radici"), 3)
	c.termina_turno()
	assert_eq(g.cariche("radici"), 3, "intensità: non cala")
