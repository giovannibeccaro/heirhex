extends GutTest
## testi.csv è importato come traduzione: tr("chiave") restituisce la frase.

var _lingua_prima: String

func before_each() -> void:
	_lingua_prima = TranslationServer.get_locale()

func after_each() -> void:
	TranslationServer.set_locale(_lingua_prima)

func test_tr_restituisce_il_testo_italiano() -> void:
	TranslationServer.set_locale("it")
	assert_eq(tr("stato.fattura.nome"), "Fattura")
	assert_eq(tr("risorsa.energia.nome"), "Energia")

func test_tr_restituisce_il_testo_inglese() -> void:
	TranslationServer.set_locale("en")
	assert_eq(tr("stato.fattura.nome"), "Hex")

func test_chiave_sconosciuta_resta_chiave() -> void:
	TranslationServer.set_locale("it")
	assert_eq(tr("chiave.che.non.esiste"), "chiave.che.non.esiste")
