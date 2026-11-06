extends GutTest
## T1.7 — Nemici: comportamenti, forme della fattura, fasi, ultimo rintocco.

const Aiuti := preload("res://test/aiuti.gd")


func _nuovo(nemici: Array, extra: Dictionary = {}) -> Combattimento:
	var base := {"nemici": nemici, "giocatore": {"vita": 9999}, "mazzo": []}
	base.merge(extra, true)
	var c := Combattimento.new(Aiuti.catalogo(), Aiuti.impostazioni(base))
	c.inizia()
	return c


## Intenzioni mostrate turno dopo turno.
func _intenzioni(c: Combattimento, turni: int, indice: int = 0) -> Array[String]:
	var viste: Array[String] = []
	for t in turni:
		viste.append(str(c.stato.nemici[indice].intenzione.get("id", "")))
		c.termina_turno()
	return viste


# --- sequenza -----------------------------------------------------------------

func test_sequenza() -> void:
	var c := _nuovo(["lupo"])
	assert_eq(_intenzioni(c, 8), ["morso", "morso", "ululato", "morso_grosso", "morso", "morso", "ululato", "morso_grosso"] as Array[String])


func test_sequenza_esegue_davvero() -> void:
	var c := _nuovo(["lupo"])
	c.termina_turno()
	c.termina_turno()
	assert_eq(c.stato.giocatore.vita, 9999 - 24)
	c.termina_turno()
	assert_eq(c.stato.nemici[0].blocco, 10)


# --- pesato -------------------------------------------------------------------

func test_pesato_rispetta_max_di_fila_e_ricarica() -> void:
	var c := _nuovo(["strega"], {"culla": {"vita": 99999, "attiva": true}})
	var viste := _intenzioni(c, 300)
	for i in range(2, viste.size()):
		assert_false(viste[i] == "graffio" and viste[i - 1] == "graffio" and viste[i - 2] == "graffio", "graffio al massimo 2 di fila")
	for i in range(1, viste.size()):
		assert_false(viste[i] == "riparo" and viste[i - 1] == "riparo", "riparo mai di fila")
	var ultimo := -100
	for i in viste.size():
		if viste[i] == "maleficio":
			assert_true(i - ultimo >= 3, "maleficio al massimo ogni 3 turni (turno %d)" % i)
			ultimo = i
	assert_gt(viste.count("graffio"), viste.count("riparo"), "il peso conta")
	assert_gt(viste.count("maleficio"), 0)
	assert_gt(viste.count("riparo"), 0)


func test_pesato_deterministico() -> void:
	var a := _intenzioni(_nuovo(["strega"], {"seme": 3, "culla": {"vita": 9999, "attiva": true}}), 30)
	var b := _intenzioni(_nuovo(["strega"], {"seme": 3, "culla": {"vita": 9999, "attiva": true}}), 30)
	assert_eq(a, b)


# --- forme della fattura --------------------------------------------------------

func test_forma_toccata() -> void:
	var c := _nuovo([{"id": "lupo", "forma": "toccata"}])
	var n := c.stato.nemici[0]
	assert_eq(n.vita_max, 94, "72 × 1,3")
	assert_eq(n.vita, 94)
	c.termina_turno()
	assert_eq(c.stato.giocatore.vita, 9999 - 14, "morso 12 × 1,15")


func test_forma_divorata() -> void:
	var c := _nuovo([{"id": "lupo", "forma": "divorata"}])
	assert_eq(c.stato.nemici[0].vita_max, 115, "72 × 1,6")
	c.termina_turno()
	assert_eq(c.stato.giocatore.vita, 9999 - 16, "morso 12 × 1,3")


func test_le_forme_aggiungono_intenzioni() -> void:
	var base := _nuovo(["lupo"]).stato.nemici[0].intenzioni_base.map(func(i: Dictionary) -> String: return i["id"])
	var toccata := _nuovo([{"id": "lupo", "forma": "toccata"}]).stato.nemici[0].intenzioni_base.map(func(i: Dictionary) -> String: return i["id"])
	var divorata := _nuovo([{"id": "lupo", "forma": "divorata"}]).stato.nemici[0].intenzioni_base.map(func(i: Dictionary) -> String: return i["id"])
	assert_false(base.has("zampata"))
	assert_true(toccata.has("zampata"))
	assert_false(toccata.has("furia"))
	assert_true(divorata.has("zampata") and divorata.has("furia"), "le forme sono cumulative")


func test_forma_e_vita_in_percentuale() -> void:
	var c := _nuovo([{"id": "lupo", "forma": "toccata", "quota_vita": 0.5}])
	assert_eq(c.stato.nemici[0].vita, 47)


# --- fasi del Tiranno -----------------------------------------------------------

func test_fase_sotto_il_50_per_cento() -> void:
	var c := _nuovo(["madre_con_fase"])
	var n := c.stato.nemici[0]
	assert_eq(n.intenzione["id"], "colpo")
	n.vita = 99
	c.termina_turno()
	assert_eq(n.fase, 1)
	assert_eq(n.intenzione["id"], "furia")
	n.vita = 200
	c.termina_turno()
	assert_eq(n.intenzione["id"], "furia", "la fase non torna indietro")


func test_fase_senza_intenzioni_resta_quella_base() -> void:
	var c := _nuovo(["madre"])
	c.stato.nemici[0].vita = 10
	c.termina_turno()
	assert_eq(c.stato.nemici[0].fase, 0)
	assert_eq(c.stato.nemici[0].intenzione["id"], "colpo")


func test_intenzioni_della_fase_date_da_fuori() -> void:
	# Le carte rubate dal Tiranno, già tradotte in intenzioni, arrivano con le impostazioni.
	var rubata := {"id": "carta_rubata", "tipo": "attacco", "effetti": [{"tipo": "danno", "valore": 7, "bersaglio": "giocatore"}]}
	var c := _nuovo([{"id": "madre", "intenzioni_fase": [rubata]}])
	c.stato.nemici[0].vita = 50
	c.termina_turno()
	assert_eq(c.stato.nemici[0].intenzione["id"], "carta_rubata")


# --- ultimo rintocco ------------------------------------------------------------

func test_ultimo_rintocco_al_turno_8() -> void:
	var c := _nuovo(["madre"], {"giocatore": {"vita": 1000}})
	for t in 7:
		assert_ne(c.stato.nemici[0].intenzione["id"], "ultimo_rintocco", "turno %d" % c.stato.turno)
		c.termina_turno()
	assert_eq(c.stato.turno, 8)
	assert_eq(c.stato.nemici[0].intenzione["id"], "ultimo_rintocco", "annunciato durante il turno 8")
	c.stato.giocatore.blocco = 5000
	Mattoncini.esegui(c, {"tipo": "annulla_intenzione", "bersaglio": "nemico"}, ContestoEffetto.new(c.stato.giocatore))
	c.termina_turno()
	assert_eq(c.stato.giocatore.vita, 0, "letale: ignora il blocco e non si annulla")
	assert_eq(c.esito, Combattimento.Esito.SCONFITTA)


func test_conto_alla_rovescia() -> void:
	var c := _nuovo(["madre"], {"giocatore": {"vita": 1000}})
	for t in 5:
		c.termina_turno()
	assert_eq(c.stato.turno, 6)
	var conto := IntelligenzaNemici.conto_alla_rovescia(c.stato.nemici[0], c.stato.turno)
	assert_eq(conto, {"intenzione": "ultimo_rintocco", "turno": 8, "mancano": 2})


func test_rintocco_anche_nella_seconda_fase() -> void:
	var c := _nuovo([{"id": "madre", "intenzioni_fase": [{"id": "x", "tipo": "attacco", "effetti": [{"tipo": "danno", "valore": 1, "bersaglio": "giocatore"}]}]}], {"giocatore": {"vita": 1000}})
	c.stato.nemici[0].vita = 10
	for t in 7:
		c.termina_turno()
	assert_eq(c.stato.nemici[0].fase, 1)
	assert_eq(c.stato.nemici[0].intenzione["id"], "ultimo_rintocco")
