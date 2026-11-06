extends GutTest
## T2.11 — Evoluzione "Più forte" (D43) e carte con livello in combattimento.

const Aiuti := preload("res://test/aiuti.gd")


func _valori(dati: Dictionary) -> Array:
	return dati["effetti"].map(func(e: Dictionary) -> Variant: return e.get("valore"))


func test_piu_forte_sui_valori_in_punti() -> void:
	var rimandare := {"id": "x", "effetti": [{"tipo": "danno", "valore": 16}, {"tipo": "rimuovi_stato", "stato": "fattura", "valore": 2}]}
	assert_eq(_valori(Invecchiamento.piu_forte(rimandare, 0.3)), [21, 2], "16 × 1,3 = 20,8; le cariche rimosse non cambiano")


func test_piu_forte_due_volte() -> void:
	var dati := {"id": "x", "effetti": [{"tipo": "danno", "valore": 16}]}
	assert_eq(_valori(Invecchiamento.applica(dati, [Id.PIU_FORTE, Id.PIU_FORTE], 0.3)), [27], "16 → 21 → 27,3")


func test_arrotondamento_a_meta() -> void:
	var aglio := {"id": "x", "effetti": [{"tipo": "blocco", "valore": 5}, {"tipo": "rimuovi_stato", "valore": 1}]}
	assert_eq(_valori(Invecchiamento.piu_forte(aglio, 0.3)), [7, 1], "5 × 1,3 = 6,5 arrotondato a 7")


func test_carta_senza_punti_pesca_o_cariche_piu_uno() -> void:
	var pesca := {"id": "x", "effetti": [{"tipo": "pesca", "valore": 2}]}
	assert_eq(_valori(Invecchiamento.piu_forte(pesca, 0.3)), [3])
	var radici := {"id": "x", "effetti": [{"tipo": "applica_stato", "stato": "radici", "valore": 2}]}
	assert_eq(_valori(Invecchiamento.piu_forte(radici, 0.3)), [3])
	var lamento := {"id": "x", "effetti": [{"tipo": "pesca", "valore": 1}, {"tipo": "applica_stato", "valore": 1}]}
	assert_eq(_valori(Invecchiamento.piu_forte(lamento, 0.3)), [2, 1], "solo il primo effetto di quel tipo")


func test_con_punti_pesca_e_cariche_non_cambiano() -> void:
	var invocare := {"id": "x", "effetti": [{"tipo": "danno", "valore": 3}, {"tipo": "applica_stato", "valore": 1}, {"tipo": "pesca", "valore": 1}]}
	assert_eq(_valori(Invecchiamento.piu_forte(invocare, 0.3)), [4, 1, 1])


func test_energia_ed_esilia_non_cambiano() -> void:
	var dati := {"id": "x", "effetti": [{"tipo": "energia", "valore": 1}, {"tipo": "esilia", "valore": 1}]}
	assert_eq(_valori(Invecchiamento.piu_forte(dati, 0.3)), [1, 1])


func test_i_dati_originali_non_cambiano() -> void:
	var dati := {"id": "x", "effetti": [{"tipo": "danno", "valore": 10}]}
	Invecchiamento.piu_forte(dati, 0.3)
	assert_eq(dati["effetti"][0]["valore"], 10)


func test_carta_con_livello_in_combattimento() -> void:
	var c := Combattimento.new(Aiuti.catalogo(), Aiuti.impostazioni({"mazzo": [
		{"id": "colpo", "livello": 2, "ereditata": true}, "colpo"], "mano": 2}))
	var invecchiata: Carta = c.stato.mazzo.filter(func(x: Carta) -> bool: return x.livello == 2)[0]
	var nuova: Carta = c.stato.mazzo.filter(func(x: Carta) -> bool: return x.livello == 0)[0]
	assert_eq(invecchiata.effetti()[0]["valore"], 17, "10 → 13 → 16,9")
	assert_eq(nuova.effetti()[0]["valore"], 10, "le altre copie non cambiano")
	assert_eq(Aiuti.catalogo().carta("colpo")["effetti"][0]["valore"], 10)


func test_rimandare_la_fattura_degli_avi_coi_dati_veri() -> void:
	var catalogo := Caricatore.new().carica()
	var c := Combattimento.new(catalogo, {"mazzo": [{"id": "rimandare_la_fattura", "livello": 2}], "nemici": []})
	assert_eq(c.stato.mazzo[0].effetti()[0]["valore"], 27)
