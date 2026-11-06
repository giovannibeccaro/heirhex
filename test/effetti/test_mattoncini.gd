extends GutTest
## T1.3 — Un test per mattoncino, con i casi limite.

const Aiuti := preload("res://test/aiuti.gd")

var c: Combattimento
var g: Combattente


func _prepara(extra: Dictionary = {}) -> void:
	c = Combattimento.new(Aiuti.catalogo(), Aiuti.impostazioni(extra))
	c.inizia()
	g = c.stato.giocatore


## Esegue un effetto come se lo giocasse il giocatore.
func _dal_giocatore(effetto: Dictionary, scelte: Dictionary = {}, carta: Carta = null) -> ContestoEffetto:
	var ctx := ContestoEffetto.new(g, carta, scelte)
	Mattoncini.esegui(c, effetto, ctx)
	return ctx


func _dal_nemico(effetto: Dictionary, n: Nemico = null) -> void:
	Mattoncini.esegui(c, effetto, ContestoEffetto.new(n if n != null else c.stato.nemici[0]))


## Sposta in mano la prima carta con quell'id (dal mazzo), per test indipendenti dal mescolamento.
func _metti_in_mano(id: String) -> Carta:
	for carta in c.stato.mazzo:
		if carta.id == id:
			c.stato.mazzo.erase(carta)
			c.stato.mano.append(carta)
			return carta
	return null


func _uids(zona: Array[Carta]) -> Array:
	return zona.map(func(x: Carta) -> int: return x.uid)


# --- danno --------------------------------------------------------------------

func test_danno_a_un_nemico() -> void:
	_prepara()
	_dal_giocatore({"tipo": "danno", "valore": 10, "bersaglio": "nemico"})
	assert_eq(c.stato.nemici[0].vita, 40)


func test_danno_blocco_che_assorbe_tutto() -> void:
	_prepara()
	var n := c.stato.nemici[0]
	n.blocco = 15
	_dal_giocatore({"tipo": "danno", "valore": 10, "bersaglio": "nemico"})
	assert_eq(n.vita, 50)
	assert_eq(n.blocco, 5)


func test_danno_blocco_parziale() -> void:
	_prepara()
	var n := c.stato.nemici[0]
	n.blocco = 4
	_dal_giocatore({"tipo": "danno", "valore": 10, "bersaglio": "nemico"})
	assert_eq(n.vita, 44)
	assert_eq(n.blocco, 0)


func test_danno_che_ignora_il_blocco() -> void:
	_prepara()
	var n := c.stato.nemici[0]
	n.blocco = 15
	_dal_giocatore({"tipo": "danno", "valore": 10, "bersaglio": "nemico", "ignora_blocco": true})
	assert_eq(n.vita, 40)
	assert_eq(n.blocco, 15)


func test_danno_in_percentuale_della_vita_massima() -> void:
	_prepara({"giocatore": {"vita": 85}})
	_dal_nemico({"tipo": "danno", "valore": 30, "percentuale": true, "bersaglio": "giocatore"})
	assert_eq(g.vita, 85 - 26, "30% di 85 = 25,5 arrotondato a 26")


func test_danno_a_tutti_i_nemici() -> void:
	_prepara({"nemici": ["fantoccio", "fantoccio", "manichino"]})
	_dal_giocatore({"tipo": "danno", "valore": 20, "bersaglio": "tutti_nemici"})
	assert_eq(c.stato.nemici[0].vita, 30)
	assert_eq(c.stato.nemici[1].vita, 30)
	assert_eq(c.stato.nemici[2].vita, 480)


func test_danno_a_un_nemico_casuale_e_deterministico() -> void:
	var colpiti := []
	for prova in 2:
		_prepara({"nemici": ["fantoccio", "fantoccio", "fantoccio"], "seme": 77})
		_dal_giocatore({"tipo": "danno", "valore": 10, "bersaglio": "nemico_casuale"})
		colpiti.append(c.stato.nemici.map(func(n: Nemico) -> int: return n.vita))
	assert_eq(colpiti[0], colpiti[1])
	assert_eq(colpiti[0].count(40), 1, "un solo nemico colpito")


func test_danno_al_nemico_scelto() -> void:
	_prepara({"nemici": ["fantoccio", "fantoccio"]})
	_dal_giocatore({"tipo": "danno", "valore": 10, "bersaglio": "nemico"}, {"nemico": c.stato.nemici[1].uid})
	assert_eq(c.stato.nemici[0].vita, 50)
	assert_eq(c.stato.nemici[1].vita, 40)


func test_bersaglio_morto_nessun_effetto() -> void:
	_prepara({"nemici": ["fantoccio", "manichino"]})
	var morto := c.stato.nemici[0]
	morto.vita = 5
	_dal_giocatore({"tipo": "danno", "valore": 10, "bersaglio": "nemico"}, {"nemico": morto.uid})
	assert_eq(morto.vita, 0, "la vita non scende sotto zero")
	assert_true(morto.intenzione.is_empty(), "un nemico morto non ha intenzioni")
	_dal_giocatore({"tipo": "danno", "valore": 10, "bersaglio": "nemico"}, {"nemico": morto.uid})
	assert_eq(c.stato.nemici[1].vita, 500, "il danno non passa a un altro nemico")


func test_carta_con_due_danni_sul_nemico_che_muore_al_primo() -> void:
	_prepara({"mazzo": ["doppio_colpo"], "nemici": [{"id": "fantoccio", "quota_vita": 0.1}, "manichino"]})
	var bersaglio := c.stato.nemici[0]
	assert_true(c.gioca_carta(c.stato.mano[0].uid, {"nemico": bersaglio.uid}))
	assert_eq(bersaglio.vita, 0)
	assert_eq(c.stato.nemici[1].vita, 500, "il secondo danno non va altrove")


func test_carta_su_nemico_morto_non_si_gioca() -> void:
	_prepara({"mazzo": ["colpo"], "nemici": ["fantoccio", "manichino"]})
	c.stato.nemici[0].vita = 0
	assert_false(c.gioca_carta(c.stato.mano[0].uid, {"nemico": c.stato.nemici[0].uid}))
	assert_eq(c.stato.energia, 3)
	assert_eq(c.stato.mano.size(), 1)


# --- blocco -------------------------------------------------------------------

func test_blocco_a_se() -> void:
	_prepara()
	_dal_giocatore({"tipo": "blocco", "valore": 7, "bersaglio": "se"})
	assert_eq(g.blocco, 7)


func test_blocco_alla_casa() -> void:
	_prepara()
	_dal_giocatore({"tipo": "blocco", "valore": 7, "bersaglio": "casa"})
	assert_eq(c.stato.casa.blocco, 7)
	assert_eq(g.blocco, 0)


func test_blocco_a_scelta() -> void:
	_prepara()
	_dal_giocatore({"tipo": "blocco", "valore": 7, "bersaglio": "se_o_casa"}, {"se_o_casa": "casa"})
	_dal_giocatore({"tipo": "blocco", "valore": 5, "bersaglio": "se_o_casa"}, {"se_o_casa": "se"})
	_dal_giocatore({"tipo": "blocco", "valore": 2, "bersaglio": "se_o_casa"})
	assert_eq(c.stato.casa.blocco, 7)
	assert_eq(g.blocco, 7, "senza scelta il blocco va a te")


func test_le_riserve_di_blocco_sono_separate() -> void:
	_prepara()
	_dal_giocatore({"tipo": "blocco", "valore": 20, "bersaglio": "se"})
	_dal_nemico({"tipo": "danno", "valore": 10, "bersaglio": "casa"})
	assert_eq(c.stato.casa.vita, 25, "il blocco del giocatore non protegge la casa")
	assert_eq(g.blocco, 20)


# --- casa --------------------------------------------------------------------

func test_casa_a_zero_tratto_negativo_e_torna_a_meta() -> void:
	_prepara()
	_dal_nemico({"tipo": "danno", "valore": 50, "bersaglio": "casa"})
	assert_eq(c.stato.casa.tratti_negativi, 1)
	assert_eq(c.stato.casa.vita, 18)
	_dal_nemico({"tipo": "danno", "valore": 50, "bersaglio": "casa"})
	assert_eq(c.stato.casa.tratti_negativi, 1, "massimo un tratto per combattimento")
	assert_false(c.finito(), "il combattimento continua")


# --- cura ---------------------------------------------------------------------

func test_cura_non_supera_la_vita_massima() -> void:
	_prepara({"giocatore": {"vita": 97, "vita_max": 100}})
	_dal_giocatore({"tipo": "cura", "valore": 5, "bersaglio": "se"})
	assert_eq(g.vita, 100)


func test_cura_alla_casa() -> void:
	_prepara({"casa": {"vita": 20, "vita_max": 35}})
	_dal_giocatore({"tipo": "cura", "valore": 3, "bersaglio": "casa"})
	assert_eq(c.stato.casa.vita, 23)


# --- pesca --------------------------------------------------------------------

func test_pesca() -> void:
	_prepara()
	_dal_giocatore({"tipo": "pesca", "valore": 2})
	assert_eq(c.stato.mano.size(), 7)
	assert_eq(c.stato.mazzo.size(), 3)


func test_pesca_con_mazzo_vuoto_rimescola_gli_scarti() -> void:
	_prepara()
	c.stato.scarti.append_array(c.stato.mazzo)
	c.stato.mazzo.clear()
	_dal_giocatore({"tipo": "pesca", "valore": 2})
	assert_eq(c.stato.mano.size(), 7)
	assert_eq(c.stato.mazzo.size(), 3)
	assert_eq(c.stato.scarti.size(), 0)


func test_pesca_con_mazzo_e_scarti_vuoti() -> void:
	_prepara({"mazzo": ["colpo", "colpo"]})
	assert_eq(c.stato.mano.size(), 2)
	_dal_giocatore({"tipo": "pesca", "valore": 3})
	assert_eq(c.stato.mano.size(), 2, "non c'è niente da pescare")


func test_pesca_rispetta_il_limite_della_mano() -> void:
	var mazzo := []
	for i in 15:
		mazzo.append("colpo")
	_prepara({"mazzo": mazzo})
	_dal_giocatore({"tipo": "pesca", "valore": 8})
	assert_eq(c.stato.mano.size(), 10)


# --- energia ------------------------------------------------------------------

func test_energia() -> void:
	_prepara()
	_dal_giocatore({"tipo": "energia", "valore": 1})
	assert_eq(c.stato.energia, 4)


# --- stati --------------------------------------------------------------------

func test_applica_e_rimuovi_stato() -> void:
	_prepara()
	_dal_giocatore({"tipo": "applica_stato", "stato": "radici", "valore": 2, "bersaglio": "se"})
	_dal_giocatore({"tipo": "applica_stato", "stato": "radici", "valore": 1, "bersaglio": "se"})
	assert_eq(g.cariche("radici"), 3)
	_dal_giocatore({"tipo": "rimuovi_stato", "stato": "radici", "valore": 2, "bersaglio": "se"})
	assert_eq(g.cariche("radici"), 1)
	_dal_giocatore({"tipo": "rimuovi_stato", "stato": "radici", "valore": 5, "bersaglio": "se"})
	assert_eq(g.cariche("radici"), 0)
	assert_false(g.stati.has("radici"))


func test_rimuovi_tutte_le_cariche() -> void:
	_prepara({"giocatore": {"vita": 100, "stati": {"malocchio": 4}}})
	_dal_giocatore({"tipo": "rimuovi_stato", "stato": "malocchio", "valore": "tutte", "bersaglio": "se"})
	assert_eq(g.cariche("malocchio"), 0)


func test_il_nemico_applica_uno_stato_al_giocatore() -> void:
	_prepara()
	_dal_nemico({"tipo": "applica_stato", "stato": "paura", "valore": 2, "bersaglio": "giocatore"})
	assert_eq(g.cariche("paura"), 2)


# --- carte --------------------------------------------------------------------

func test_aggiungi_carta_in_mano_mazzo_scarti() -> void:
	_prepara()
	_dal_nemico({"tipo": "aggiungi_carta", "carta": "sporco", "dove": "mano"})
	_dal_nemico({"tipo": "aggiungi_carta", "carta": "sporco", "dove": "scarti", "valore": 2})
	_dal_nemico({"tipo": "aggiungi_carta", "carta": "sporco"})
	assert_eq(c.stato.mano.filter(func(x: Carta) -> bool: return x.id == "sporco").size(), 1)
	assert_eq(c.stato.scarti.size(), 2)
	assert_eq(c.stato.mazzo.filter(func(x: Carta) -> bool: return x.id == "sporco").size(), 1)
	assert_eq(c.stato.tutte_le_carte().size(), 14)


func test_carta_negativa_non_si_gioca() -> void:
	_prepara({"mazzo": ["sporco"]})
	assert_false(c.gioca_carta(c.stato.mano[0].uid))


func test_scarta_a_scelta() -> void:
	_prepara()
	var scelta := c.stato.mano[3]
	_dal_giocatore({"tipo": "scarta", "valore": 1}, {"scarta": [scelta.uid]})
	assert_true(c.stato.scarti.has(scelta))
	assert_eq(c.stato.mano.size(), 4)


func test_scarta_a_caso() -> void:
	_prepara()
	_dal_giocatore({"tipo": "scarta", "valore": 2, "modo": "casuale"})
	assert_eq(c.stato.mano.size(), 3)
	assert_eq(c.stato.scarti.size(), 2)


func test_scarta_piu_carte_di_quelle_in_mano() -> void:
	_prepara({"mazzo": ["colpo", "colpo"]})
	_dal_giocatore({"tipo": "scarta", "valore": 5, "modo": "casuale"})
	assert_eq(c.stato.mano.size(), 0)
	assert_eq(c.stato.scarti.size(), 2)


func test_esilia_la_carta_giocata() -> void:
	_prepara({"mazzo": ["pane", "colpo", "colpo"], "mano": 0})
	var pane := _metti_in_mano("pane")
	var in_mano := c.stato.mano.size()
	assert_true(c.gioca_carta(pane.uid))
	assert_true(c.stato.esilio.has(pane))
	assert_false(c.stato.scarti.has(pane))
	assert_eq(c.stato.mano.size(), in_mano - 1 + 2)


func test_esilia_dopo_uso() -> void:
	_prepara({"mazzo": ["svanisce"]})
	var carta := c.stato.mano[0]
	c.gioca_carta(carta.uid)
	assert_true(c.stato.esilio.has(carta))
	assert_eq(g.blocco, 11)


func test_esilia_una_carta_scelta_dalla_mano() -> void:
	_prepara()
	var scelta := c.stato.mano[1]
	_dal_giocatore({"tipo": "esilia", "bersaglio": "mano", "valore": 1}, {"esilia": [scelta.uid]})
	assert_true(c.stato.esilio.has(scelta))
	assert_false(c.stato.mano.has(scelta))


func test_riprendi_dagli_scarti() -> void:
	_prepara()
	c.termina_turno()
	var scelta := c.stato.scarti[2]
	_dal_giocatore({"tipo": "riprendi_dagli_scarti", "valore": 1}, {"riprendi": [scelta.uid]})
	assert_true(c.stato.mano.has(scelta))
	assert_eq(c.stato.mano.size(), 6)
	assert_eq(c.stato.scarti.size(), 4)


func test_riprendi_senza_scelta_prende_l_ultima_scartata() -> void:
	_prepara()
	c.termina_turno()
	var ultima: Carta = c.stato.scarti.back()
	_dal_giocatore({"tipo": "riprendi_dagli_scarti", "valore": 1})
	assert_true(c.stato.mano.has(ultima))


func test_riprendi_con_scarti_vuoti() -> void:
	_prepara()
	_dal_giocatore({"tipo": "riprendi_dagli_scarti", "valore": 1})
	assert_eq(c.stato.mano.size(), 5)


# --- nemici -------------------------------------------------------------------

func test_annulla_intenzione() -> void:
	_prepara()
	_dal_giocatore({"tipo": "annulla_intenzione", "bersaglio": "nemico", "valore": 1})
	c.termina_turno()
	assert_eq(g.vita, 100, "il pugno è annullato")
	c.termina_turno()
	assert_eq(g.vita, 95, "solo per un turno")


func test_intenzione_non_annullabile() -> void:
	_prepara({"nemici": ["inarrestabile"]})
	_dal_giocatore({"tipo": "annulla_intenzione", "bersaglio": "nemico", "valore": 1})
	c.termina_turno()
	assert_eq(g.vita, 91)


func test_ruba_una_carta_della_mano_appena_scartata() -> void:
	_prepara({"nemici": ["ladro"]})
	var prima := _uids(c.stato.mano)
	c.termina_turno()
	assert_eq(c.stato.rubate.size(), 1)
	var rubata := c.stato.rubate[0]
	assert_true(prima.has(rubata.uid))
	assert_eq(c.stato.nemici[0].carte_rubate, [rubata.uid])
	assert_false(c.stato.mano.has(rubata))
	assert_false(c.stato.scarti.has(rubata))
	assert_eq(c.stato.tutte_le_carte().size(), 10)


func test_ruba_dalla_mano_durante_il_turno_del_giocatore() -> void:
	_prepara({"nemici": ["ladro"]})
	var prima := _uids(c.stato.mano)
	_dal_nemico({"tipo": "ruba_carta", "da": "mano", "valore": 1})
	assert_eq(c.stato.mano.size(), 4)
	assert_true(prima.has(c.stato.rubate[0].uid))


func test_ruba_dal_mazzo() -> void:
	_prepara({"nemici": ["ladro"]})
	_dal_nemico({"tipo": "ruba_carta", "da": "mazzo", "valore": 2})
	assert_eq(c.stato.mazzo.size(), 3)
	assert_eq(c.stato.rubate.size(), 2)


func test_ruba_senza_carte_disponibili() -> void:
	_prepara({"nemici": ["ladro"]})
	c.stato.mano.clear()
	_dal_nemico({"tipo": "ruba_carta", "da": "mano", "valore": 1})
	assert_eq(c.stato.rubate.size(), 0)


func test_evoca() -> void:
	_prepara({"nemici": ["evocatore"]})
	c.termina_turno()
	assert_eq(c.stato.nemici.size(), 2)
	var evocato := c.stato.nemici[1]
	assert_eq(evocato.id, "fantoccio")
	assert_false(evocato.intenzione.is_empty(), "l'evocato mostra subito l'intenzione")
	assert_eq(g.vita, 100, "l'evocato non agisce nel turno in cui arriva")
	c.termina_turno()
	assert_eq(g.vita, 95)


func test_evoca_rispetta_il_limite() -> void:
	_prepara({"nemici": ["evocatore", "manichino", "manichino", "manichino", "manichino"]})
	c.termina_turno()
	assert_eq(c.stato.nemici.size(), 5)
	assert_eq(c.registro.conta("evocazione_fallita"), 1)
