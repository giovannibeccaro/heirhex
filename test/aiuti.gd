extends RefCounted
## Funzioni comuni ai test: catalogo di prova dai file in test/fixtures/.

const CARTELLA := "res://test/fixtures/"


static func leggi_json(percorso: String) -> Variant:
	var testo := FileAccess.get_file_as_string(percorso)
	assert(testo != "", "File mancante o vuoto: " + percorso)
	return JSON.parse_string(testo)


static func catalogo() -> Catalogo:
	var c := Catalogo.new()
	c.carte = Catalogo.indicizza(leggi_json(CARTELLA + "carte.json")["carte"])
	c.nemici = Catalogo.indicizza(leggi_json(CARTELLA + "nemici.json")["nemici"])
	# Stati di prova + gli stati veri (scritti a mano, non dipendono dall'esportazione)
	c.stati = Catalogo.indicizza(leggi_json(CARTELLA + "stati.json")["stati"])
	c.bilanciamento = leggi_json(CARTELLA + "bilanciamento.json")
	c.stati.merge(Catalogo.indicizza(leggi_json("res://data/manuali/stati.json")["stati"]))
	# Come il caricatore vero: identificatori convertiti e controllati anche nei dati di prova
	var errori := Caricatore.normalizza(c)
	assert(errori.is_empty(), "\n".join(errori))
	return c


## Impostazioni minime di un combattimento, sovrascrivibili.
static func impostazioni(extra: Dictionary = {}) -> Dictionary:
	var base := {
		"seme": 42,
		"mazzo": ["colpo", "colpo", "colpo", "colpo", "riparo", "riparo", "riparo", "riparo", "pesca_due", "colpo_grosso"],
		"nemici": ["fantoccio"],
		"giocatore": {"vita": 100},
		"casa": {"vita": 35},
		"mano": 5,
	}
	base.merge(extra, true)
	return base
