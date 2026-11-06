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


# --- T1.9: identificatori convertiti e controllati al caricamento -------------------

func _catalogo(carta_effetti: Array, stato_extra: Dictionary = {}) -> Catalogo:
	var c := Catalogo.new()
	c.carte = {"a": {"id": "a", "tipo": "attacco", "effetti": carta_effetti}}
	var s := {"id": "s", "tipo": "durata"}
	s.merge(stato_extra, true)
	c.stati = {"s": s}
	return c


func test_gli_identificatori_diventano_stringname() -> void:
	var c := _catalogo([{"tipo": "danno", "valore": 10, "bersaglio": "nemico"}])
	assert_eq(Caricatore.normalizza(c).size(), 0)
	var e: Dictionary = c.carte["a"]["effetti"][0]
	assert_typeof(e["tipo"], TYPE_STRING_NAME)
	assert_eq(e["tipo"], Id.DANNO)
	assert_eq(e["bersaglio"], Id.NEMICO)
	assert_typeof(c.carte["a"]["tipo"], TYPE_STRING_NAME)


func test_dati_veri_convertiti() -> void:
	var catalogo := Caricatore.new().carica()
	for id in catalogo.carte:
		for e in catalogo.carte[id]["effetti"]:
			assert_typeof(e["tipo"], TYPE_STRING_NAME, id)


func test_rifiuta_un_tipo_di_effetto_sconosciuto() -> void:
	var errori := Caricatore.normalizza(_catalogo([{"tipo": "dano", "valore": 10}]))
	assert_eq(errori.size(), 1)
	assert_string_contains(errori[0], "tipo sconosciuto 'dano'")


func test_rifiuta_un_bersaglio_sconosciuto() -> void:
	var errori := Caricatore.normalizza(_catalogo([{"tipo": "danno", "bersaglio": "culla"}]))
	assert_string_contains("\n".join(errori), "bersaglio sconosciuto 'culla'")


func test_rifiuta_zone_e_modi_sconosciuti() -> void:
	var errori := Caricatore.normalizza(_catalogo([{"tipo": "aggiungi_carta", "carta": "a", "dove": "tasca"},
		{"tipo": "scarta", "modo": "forse"}, {"tipo": "rimuovi_stato", "stato": "s", "valore": "molte"}]))
	var testo := "\n".join(errori)
	assert_string_contains(testo, "dove sconosciuto 'tasca'")
	assert_string_contains(testo, "modo sconosciuto 'forse'")
	assert_string_contains(testo, "valore sconosciuto 'molte'")


func test_rifiuta_evento_e_modificatore_sconosciuti() -> void:
	var errori := Caricatore.normalizza(_catalogo([], {
		"agganci": [{"quando": "alba", "effetti": []}],
		"modificatori": [{"bersaglio": {"tipo": "carta", "filtro": {"colore": 1}}, "proprieta": "fortuna", "operazione": "dividi", "durata": "sempre"}]}))
	var testo := "\n".join(errori)
	for atteso in ["quando sconosciuto 'alba'", "filtro sconosciuto 'colore'", "proprieta sconosciuto 'fortuna'",
			"operazione sconosciuto 'dividi'", "durata sconosciuto 'sempre'"]:
		assert_string_contains(testo, atteso)


func test_il_caricatore_rifiuta_dati_con_identificatori_sbagliati() -> void:
	DirAccess.make_dir_recursive_absolute(CARTELLA_PROVA + "gen/")
	DirAccess.make_dir_recursive_absolute(CARTELLA_PROVA + "man/")
	_scrivi("gen/carte.json", '{"schema": 1, "carte": [{"id": "a", "tipo": "attacco", "effetti": [{"tipo": "danno", "bersaglio": "lune"}]}]}')
	_scrivi("gen/nemici.json", '{"schema": 1, "nemici": []}')
	_scrivi("gen/bilanciamento.json", '{"schema": 2}')
	_scrivi("man/stati.json", '{"schema": 1, "stati": []}')
	var caricatore := Caricatore.new()
	assert_null(caricatore.carica(CARTELLA_PROVA + "gen/", CARTELLA_PROVA + "man/"))
	assert_string_contains(caricatore.errori[0], "bersaglio sconosciuto 'lune'")


func test_elenchi_di_id_senza_doppioni() -> void:
	for elenco in [Id.EFFETTI_COMBATTIMENTO, Id.BERSAGLI, Id.EVENTI, Id.PROPRIETA, Id.FILTRI, Id.DURATE]:
		var visti := {}
		for valore in elenco:
			assert_false(visti.has(valore), str(valore))
			visti[valore] = true


# --- D62: intenzione potenziata letta dai dati ------------------------------------

func test_intenzioni_potenziate_lette_dai_dati_veri() -> void:
	var catalogo := Caricatore.new().carica()
	var trovate := 0
	for id in catalogo.nemici:
		var potenziate: Array = catalogo.nemici[id].get("forme", {}).get("divorata", {}).get("intenzioni_potenziate", [])
		assert_true(potenziate.size() <= 1, "al massimo una per nemico: " + id)
		trovate += potenziate.size()
	assert_gt(trovate, 0, "il foglio indica almeno un'intenzione potenziata")


## I valori divorati calcolati dal motore coincidono con la colonna J "Valore divorata" del foglio.
func test_valori_divorati_come_nel_foglio() -> void:
	var catalogo := Caricatore.new().carica()
	var attesi := {"lupenaro": ["morso_della_luna", 55], "janara": ["assalto_alla_casa", 25],
		"pantafica": ["peso_sul_cuore", 25], "munaciello_offeso": ["sgambetto", 20]}
	for id in attesi:
		var c := Combattimento.new(catalogo, {"nemici": [{"id": id, "forma": "divorata"}], "mazzo": []})
		var n := c.stato.nemici[0]
		var intenzione := IntelligenzaNemici.cerca(n.intenzioni_base, attesi[id][0])
		var bersaglio: Combattente = c.stato.casa if attesi[id][0] == "assalto_alla_casa" else c.stato.giocatore
		assert_eq(c.valore_effetto(intenzione["effetti"][0], ContestoEffetto.new(n), bersaglio), attesi[id][1], id)


func test_intenzioni_potenziate_non_valide() -> void:
	var c := Catalogo.new()
	c.nemici = {"n": {"id": "n", "intenzioni": [], "forme": {"divorata": {"intenzioni_potenziate": "morso"}}}}
	assert_string_contains("\n".join(Caricatore.normalizza(c)), "intenzioni_potenziate deve essere un elenco")


# --- T2.10: mazzi di riferimento e obiettivi delle forme (D65) ---------------------

func test_mazzi_di_riferimento_e_obiettivi_dai_dati_veri() -> void:
	var b := Caricatore.new().carica().bilanciamento
	var mazzi: Dictionary = b["mazzi_riferimento"]
	assert_gt(mazzi.size(), 0)
	for forma in b["forme"]:
		var f: Dictionary = b["forme"][forma]
		assert_true(mazzi.has(f["mazzo_riferimento"]), forma)
		assert_true(f["obiettivi"]["turni_min"] <= f["obiettivi"]["turni_max"], forma)
		assert_true(f["obiettivi"]["vita_persa_min"] <= f["obiettivi"]["vita_persa_max"], forma)
	for fase in mazzi:
		for voce in mazzi[fase]["carte"]:
			assert_typeof(voce["livello"], TYPE_INT, voce["carta"])


func test_bilanciamento_con_lo_schema_vecchio_rifiutato() -> void:
	var caricatore := Caricatore.new()
	caricatore.leggi(_scrivi("bil1.json", '{"schema": 1}'), Caricatore.SCHEMI_BILANCIAMENTO)
	assert_string_contains(caricatore.errori[0], "schema 1 non supportato")
