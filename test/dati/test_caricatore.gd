extends GutTest
## T2.2 — Caricatore dei dati con controllo della versione di schema.

const CARTELLA_PROVA := "user://test_caricatore/"


func before_all() -> void:
	DirAccess.make_dir_recursive_absolute(CARTELLA_PROVA)


func _scrivi(nome: String, testo: String) -> String:
	var f := FileAccess.open(CARTELLA_PROVA + nome, FileAccess.WRITE)
	f.store_string(testo)
	f.close()
	return CARTELLA_PROVA + nome


func test_carica_i_dati_generati() -> void:
	var caricatore := Caricatore.new()
	var catalogo := caricatore.carica()
	assert_eq(caricatore.errori.size(), 0, "\n".join(caricatore.errori))
	assert_not_null(catalogo)
	assert_gt(catalogo.carte.size(), 10)
	assert_gt(catalogo.nemici.size(), 2)
	assert_eq(catalogo.stati.size(), 4)
	assert_true(catalogo.bilanciamento.has("forme"))


func test_i_numeri_interi_restano_interi() -> void:
	var catalogo := Caricatore.new().carica()
	for id in catalogo.carte:
		assert_typeof(catalogo.carte[id]["costo"], TYPE_INT, id)


func test_ogni_mazzo_base_esiste() -> void:
	var catalogo := Caricatore.new().carica()
	for casata in catalogo.bilanciamento["mazzi_base"]:
		for voce in catalogo.bilanciamento["mazzi_base"][casata]:
			assert_true(catalogo.carte.has(voce["carta"]), voce["carta"])


func test_regole_dal_bilanciamento() -> void:
	var catalogo := Caricatore.new().carica()
	var regole := RegoleCombattimento.da_bilanciamento(catalogo.bilanciamento)
	assert_eq(regole.energia_per_turno, int(catalogo.bilanciamento["ancore"]["energia_per_turno"]))


func test_un_combattimento_con_i_dati_veri() -> void:
	var catalogo := Caricatore.new().carica()
	var mazzo := []
	for voce in catalogo.bilanciamento["mazzi_base"].values()[0]:
		for i in int(voce["copie"]):
			mazzo.append(voce["carta"])
	var primo_nemico: String = catalogo.nemici.keys()[0]
	var c := Combattimento.new(catalogo, {"seme": 1, "mazzo": mazzo, "nemici": [primo_nemico], "giocatore": {"vita": 100}, "mano": 5})
	c.inizia()
	for t in 3:
		for carta in c.stato.mano.duplicate():
			c.gioca_carta(carta.uid)
		c.termina_turno()
	assert_gt(c.registro.conta("carta_giocata"), 0)


func test_schema_non_supportato() -> void:
	var caricatore := Caricatore.new()
	var dati := caricatore.leggi(_scrivi("futuro.json", '{"schema": 99, "carte": []}'))
	assert_eq(dati, {})
	assert_eq(caricatore.errori.size(), 1)
	assert_string_contains(caricatore.errori[0], "schema 99 non supportato")


func test_schema_mancante() -> void:
	var caricatore := Caricatore.new()
	caricatore.leggi(_scrivi("senza.json", '{"carte": []}'))
	assert_string_contains(caricatore.errori[0], "manca il campo schema")


func test_json_non_valido() -> void:
	var caricatore := Caricatore.new()
	caricatore.leggi(_scrivi("rotto.json", '{"schema": 1, "carte": [}'))
	assert_string_contains(caricatore.errori[0], "JSON non valido")


func test_file_mancante() -> void:
	var caricatore := Caricatore.new()
	assert_null(caricatore.carica("user://non_esiste/", "user://non_esiste/"))
	assert_eq(caricatore.errori.size(), 4)
