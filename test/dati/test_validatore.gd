extends GutTest
## T2.3 — Validatore dei dati.


func _catalogo_minimo() -> Catalogo:
	var c := Catalogo.new()
	c.carte = {"a": {"id": "a", "nome": "t.a", "tipo": "attacco", "rarita": "comune", "costo": 1,
		"effetti": [{"tipo": "danno", "valore": 10, "bersaglio": "nemico"}]}}
	c.nemici = {"n": {"id": "n", "nome": "t.n", "vita": 10, "comportamento": "pesato",
		"intenzioni": [{"id": "x", "effetti": [{"tipo": "danno", "valore": 1, "bersaglio": "giocatore"}]}]}}
	c.stati = {"s": {"id": "s", "nome": "t.s", "tipo": "durata"}}
	c.bilanciamento = {"mazzi_base": {"casata": [{"carta": "a", "copie": 2}]}}
	return c


func _testi() -> Dictionary:
	return {"t.a": "A", "t.n": "N", "t.s": "S"}


func _errori(c: Catalogo, testi: Dictionary = _testi()) -> String:
	var v := Validatore.new()
	v.valida(c, testi)
	return "\n".join(v.errori)


func test_i_dati_attuali_sono_validi() -> void:
	var caricatore := Caricatore.new()
	var catalogo := caricatore.carica()
	var v := Validatore.new()
	var ok := v.valida(catalogo, Validatore.leggi_testi("res://testi/testi.csv"))
	assert_true(ok, "\n".join(v.errori))
	assert_eq(v.chiavi_mancanti.size(), 0)


func test_catalogo_minimo_valido() -> void:
	assert_eq(_errori(_catalogo_minimo()), "")


func test_stato_inesistente() -> void:
	var c := _catalogo_minimo()
	c.carte["a"]["effetti"].append({"tipo": "applica_stato", "stato": "boh", "valore": 1, "bersaglio": "se"})
	assert_string_contains(_errori(c), "stato inesistente 'boh'")


func test_carta_inesistente() -> void:
	var c := _catalogo_minimo()
	c.nemici["n"]["intenzioni"][0]["effetti"].append({"tipo": "aggiungi_carta", "carta": "boh"})
	assert_string_contains(_errori(c), "carta inesistente 'boh'")
	c = _catalogo_minimo()
	c.bilanciamento["mazzi_base"]["casata"].append({"carta": "zzz", "copie": 1})
	assert_string_contains(_errori(c), "mazzo base casata: carta inesistente 'zzz'")


func test_nemico_evocato_inesistente() -> void:
	var c := _catalogo_minimo()
	c.nemici["n"]["intenzioni"][0]["effetti"].append({"tipo": "evoca", "nemico": "boh"})
	assert_string_contains(_errori(c), "nemico inesistente 'boh'")


func test_tipo_e_bersaglio_sconosciuti() -> void:
	var c := _catalogo_minimo()
	c.carte["a"]["effetti"].append({"tipo": "teletrasporto", "bersaglio": "luna"})
	var e := _errori(c)
	assert_string_contains(e, "tipo sconosciuto 'teletrasporto'")
	assert_string_contains(e, "bersaglio sconosciuto 'luna'")


func test_effetti_fuori_combattimento_solo_nel_lascito() -> void:
	var c := _catalogo_minimo()
	c.carte["a"]["lascito"] = {"momento": "inizio_vita", "effetti": [{"tipo": "vita_max", "valore": 5, "bersaglio": "se"}]}
	assert_eq(_errori(c), "")
	c.carte["a"]["effetti"].append({"tipo": "vita_max", "valore": 5})
	assert_string_contains(_errori(c), "tipo sconosciuto 'vita_max'")


func test_sequenza_con_intenzione_inesistente() -> void:
	var c := _catalogo_minimo()
	c.nemici["n"]["comportamento"] = "sequenza"
	c.nemici["n"]["sequenza"] = ["x", "y"]
	assert_string_contains(_errori(c), "intenzione inesistente 'y'")


func test_chiavi_di_testo_mancanti() -> void:
	var v := Validatore.new()
	v.valida(_catalogo_minimo(), {"t.a": "A"})
	assert_eq(Array(v.chiavi_mancanti), ["t.n", "t.s"])


func test_stato_con_evento_e_filtro_sconosciuti() -> void:
	var c := _catalogo_minimo()
	c.stati["s"]["agganci"] = [{"quando": "luna_piena", "effetti": []}]
	c.stati["s"]["modificatori"] = [{"bersaglio": {"tipo": "carta", "filtro": {"colore": "rosso"}}, "proprieta": "costo", "operazione": "somma", "valore": 1}]
	var e := _errori(c)
	assert_string_contains(e, "quando sconosciuto 'luna_piena'")
	assert_string_contains(e, "filtro sconosciuto 'colore'")


func test_avviso_di_budget() -> void:
	var c := _catalogo_minimo()
	c.carte["a"]["budget"] = {"esito": "Troppo forte", "scostamento": 0.4}
	var v := Validatore.new()
	assert_true(v.valida(c, _testi()), "un avviso non è un errore")
	assert_eq(v.avvisi.size(), 1)


func test_intenzione_potenziata_inesistente_o_doppia() -> void:
	var c := _catalogo_minimo()
	c.nemici["n"]["forme"] = {"divorata": {"intenzioni_potenziate": ["boh"]}}
	assert_string_contains(_errori(c), "potenzia l'intenzione inesistente 'boh'")
	c = _catalogo_minimo()
	c.nemici["n"]["intenzioni"].append({"id": "y", "effetti": []})
	c.nemici["n"]["forme"] = {"divorata": {"intenzioni_potenziate": ["x", "y"]}}
	var v := Validatore.new()
	assert_true(v.valida(c, _testi()))
	assert_string_contains("\n".join(v.avvisi), "al massimo una")


func _con_mazzi() -> Catalogo:
	var c := _catalogo_minimo()
	c.bilanciamento["invecchiamento"] = {"livelli": [{"livello": 0}, {"livello": 1}, {"livello": 2}]}
	c.bilanciamento["mazzi_riferimento"] = {"inizio": {"generazione": 1, "carte": [{"carta": "a", "copie": 2, "livello": 1}]}}
	c.bilanciamento["forme"] = {"base": {"vita": 1, "danno": 1, "mazzo_riferimento": "inizio",
		"obiettivi": {"turni_min": 4, "turni_max": 4, "vita_persa_min": 0.08, "vita_persa_max": 0.12}}}
	return c


func test_mazzi_di_riferimento_validi() -> void:
	assert_eq(_errori(_con_mazzi()), "")


func test_mazzo_di_riferimento_con_carta_o_livello_sbagliati() -> void:
	var c := _con_mazzi()
	c.bilanciamento["mazzi_riferimento"]["inizio"]["carte"].append({"carta": "zzz", "copie": 1, "livello": 0})
	c.bilanciamento["mazzi_riferimento"]["inizio"]["carte"].append({"carta": "a", "copie": 1, "livello": 3})
	var e := _errori(c)
	assert_string_contains(e, "carta inesistente 'zzz'")
	assert_string_contains(e, "livello non valido 3")


func test_ogni_forma_ha_un_mazzo_e_gli_obiettivi() -> void:
	var c := _con_mazzi()
	c.bilanciamento["forme"]["toccata"] = {"vita": 1.3, "danno": 1.15}
	var e := _errori(c)
	assert_string_contains(e, "forma toccata: manca il mazzo di riferimento")
	assert_string_contains(e, "forma toccata: mancano gli obiettivi")
	c = _con_mazzi()
	c.bilanciamento["forme"]["base"]["mazzo_riferimento"] = "fine"
	assert_string_contains(_errori(c), "mazzo di riferimento inesistente 'fine'")
