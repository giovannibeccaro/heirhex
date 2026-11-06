extends SceneTree
## Validatore dei dati da terminale (vedi docs/COMANDI.md).
##   godot --headless --path . -s res://strumenti/valida.gd
##   godot --headless --path . -s res://strumenti/valida.gd -- --correggi
## Con --correggi aggiunge a testi.csv le chiavi mancanti, con il nome italiano provvisorio
## preso da data/generati/testi_provvisori.csv (colonna inglese vuota: da tradurre).

const TESTI := "res://testi/testi.csv"
const PROVVISORI := "res://data/generati/testi_provvisori.csv"


func _initialize() -> void:
	var correggi := "--correggi" in OS.get_cmdline_user_args()
	var caricatore := Caricatore.new()
	var catalogo := caricatore.carica()
	if catalogo == null:
		for e in caricatore.errori:
			printerr("ERRORE  ", e)
		quit(1)
		return
	var validatore := Validatore.new()
	validatore.valida(catalogo, Validatore.leggi_testi(TESTI))
	if correggi and not validatore.chiavi_mancanti.is_empty():
		var aggiunte := aggiungi_chiavi(validatore.chiavi_mancanti)
		print("Aggiunte %d chiavi a testi.csv" % aggiunte)
		validatore.valida(catalogo, Validatore.leggi_testi(TESTI))
	for a in validatore.avvisi:
		print("AVVISO  ", a)
	for e in validatore.errori:
		printerr("ERRORE  ", e)
	print("Validazione: %d errori, %d avvisi" % [validatore.errori.size(), validatore.avvisi.size()])
	quit(0 if validatore.errori.is_empty() else 1)


func aggiungi_chiavi(chiavi: PackedStringArray) -> int:
	var provvisori := Validatore.leggi_testi(PROVVISORI)
	var f := FileAccess.open(TESTI, FileAccess.READ_WRITE)
	f.seek_end()
	var aggiunte := 0
	for k in chiavi:
		var it: String = provvisori.get(k, "")
		if it == "":
			printerr("ATTENZIONE  nessun nome provvisorio per ", k)
		f.store_csv_line(PackedStringArray([k, it, ""]))
		aggiunte += 1
	f.close()
	return aggiunte
