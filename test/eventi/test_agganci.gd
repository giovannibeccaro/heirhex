extends GutTest
## T1.6 — Agganci agli eventi di gioco: stati e modificatori reagiscono.

const Aiuti := preload("res://test/aiuti.gd")

var ricevuti: Array = []


func _nuovo(extra: Dictionary = {}) -> Combattimento:
	var c := Combattimento.new(Aiuti.catalogo(), Aiuti.impostazioni(extra))
	c.inizia()
	return c


func _registra(dati: Dictionary) -> void:
	ricevuti.append(dati)


func test_uno_stato_reagisce_al_suo_aggancio() -> void:
	var c := _nuovo({"nemici": ["manichino"], "giocatore": {"vita": 100, "stati": {"brucia": 2}}})
	assert_eq(c.stato.giocatore.vita, 97, "inizio del turno 1: brucia")
	assert_eq(c.stato.giocatore.cariche("brucia"), 2)


func test_lo_stato_a_durata_cala_a_fine_turno_e_sparisce() -> void:
	var c := _nuovo({"nemici": ["manichino"], "giocatore": {"vita": 100, "stati": {"brucia": 2}}})
	c.termina_turno()
	assert_eq(c.stato.giocatore.vita, 94)
	assert_eq(c.stato.giocatore.cariche("brucia"), 1)
	c.termina_turno()
	assert_eq(c.stato.giocatore.cariche("brucia"), 0)
	c.termina_turno()
	assert_eq(c.stato.giocatore.vita, 94, "finito, non brucia più")


func test_lo_stato_reagisce_solo_agli_eventi_di_chi_lo_porta() -> void:
	var c := _nuovo({"nemici": ["manichino"]})
	var n := c.stato.nemici[0]
	c.applica_stato(n, "brucia", 1)
	assert_eq(n.vita, 500, "il turno del giocatore non fa bruciare il nemico")
	c.termina_turno()
	assert_eq(n.vita, 497, "brucia all'inizio del turno del nemico")
	assert_eq(n.cariche("brucia"), 0, "e cala alla fine del suo turno")


func test_soglia_raggiunta() -> void:
	var c := _nuovo({"nemici": ["manichino"]})
	var g := c.stato.giocatore
	c.applica_stato(g, "accumulo", 2)
	assert_eq(g.vita, 100)
	c.applica_stato(g, "accumulo", 2)
	assert_eq(g.vita, 90, "a 3 cariche la soglia scatta")
	assert_eq(g.cariche("accumulo"), 0, "e si azzera")


func test_carta_giocata() -> void:
	var c := _nuovo({"nemici": ["manichino"], "giocatore": {"vita": 100, "stati": {"eco": 1}}})
	c.gioca_carta(c.stato.mano[0].uid)
	assert_true(c.stato.giocatore.blocco >= 1)
	assert_eq(c.registro.conta("aggancio_stato"), 1)


func test_modificatore_per_carica_da_uno_stato() -> void:
	var c := _nuovo({"mazzo": ["colpo"], "giocatore": {"vita": 100, "stati": {"vigore": 3}}})
	c.gioca_carta(c.stato.mano[0].uid)
	assert_eq(c.stato.nemici[0].vita, 37, "10 + 3")


func test_modificatore_dello_stato_sul_portatore() -> void:
	var c := _nuovo({"nemici": ["fantoccio", "fantoccio"], "mazzo": ["colpo", "colpo"]})
	c.applica_stato(c.stato.nemici[1], "fragile", 1)
	c.gioca_carta(c.stato.mano[0].uid, {"nemico": c.stato.nemici[0].uid})
	c.gioca_carta(c.stato.mano[0].uid, {"nemico": c.stato.nemici[1].uid})
	assert_eq(c.stato.nemici[0].vita, 40)
	assert_eq(c.stato.nemici[1].vita, 30, "solo il nemico fragile subisce il doppio")


func test_aggancio_esterno_a_inizio_combattimento() -> void:
	var c := _nuovo({"agganci": [{"quando": "inizio_combattimento",
		"effetti": [{"tipo": "applica_stato", "stato": "vigore", "valore": 1, "bersaglio": "se"}]}]})
	assert_eq(c.stato.giocatore.cariche("vigore"), 1)


func test_ascoltatore_riceve_gli_eventi_in_ordine() -> void:
	ricevuti.clear()
	var c := Combattimento.new(Aiuti.catalogo(), Aiuti.impostazioni({"nemici": ["manichino"]}))
	for evento in Id.EVENTI:
		c.eventi.ascolta(evento, _registra.bind())
	c.eventi.ascolta(Id.INIZIO_TURNO, func(d: Dictionary) -> void: ricevuti.append({"etichetta": "turno"}))
	c.inizia()
	c.gioca_carta(c.stato.mano[0].uid)
	c.termina_turno()
	var tipi := ricevuti.map(func(d: Dictionary) -> String:
		if d.has("etichetta"): return "*"
		if d.has("carta"): return "carta"
		return "giocatore" if d.get("chi") is Combattente and not (d["chi"] is Nemico) else "nemico")
	# inizio combattimento (g, n), inizio turno g, carta, fine turno g, inizio turno n, fine turno n, inizio turno g
	assert_eq(tipi, ["giocatore", "nemico", "giocatore", "*", "carta", "giocatore", "nemico", "*", "nemico", "giocatore", "*"])


func test_fine_combattimento() -> void:
	ricevuti.clear()
	var c := Combattimento.new(Aiuti.catalogo(), Aiuti.impostazioni({"mazzo": ["colpo"], "nemici": [{"id": "fantoccio", "quota_vita": 0.1}]}))
	c.eventi.ascolta(Id.FINE_COMBATTIMENTO, _registra)
	c.inizia()
	c.gioca_carta(c.stato.mano[0].uid)
	assert_eq(ricevuti, [{"esito": "vittoria"}])


func test_i_modificatori_scadono_con_gli_eventi() -> void:
	var imp := Aiuti.impostazioni({"nemici": ["manichino"]})
	imp["modificatori"] = [{"bersaglio": {"tipo": "giocatore"}, "proprieta": "energia", "operazione": "somma", "valore": 1, "durata": "turno"}]
	var c := Combattimento.new(Aiuti.catalogo(), imp)
	c.inizia()
	assert_eq(c.stato.modificatori.lista.size(), 1)
	c.emetti(Id.FINE_TURNO, {"chi": c.stato.nemici[0]})
	assert_eq(c.stato.modificatori.lista.size(), 1, "la fine del turno di un nemico non conta")
	c.emetti(Id.FINE_TURNO, {"chi": c.stato.giocatore})
	assert_eq(c.stato.modificatori.lista.size(), 0)
