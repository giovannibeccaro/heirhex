extends SceneTree
## Simulazione di bilanciamento (D65, vedi docs/COMANDI.md):
##   godot --headless --path . -s res://strumenti/simula.gd [-- --combattimenti 1000]
##   … -- --proposta res://docs/proposta-taratura.json --report res://docs/report-proposta.md
## Con --proposta i numeri proposti si applicano solo in memoria (foglio e dati non cambiano).
## Ogni forma della fattura contro il mazzo di riferimento della sua fase, in tutte le età,
## con tre strategie; confronto con gli obiettivi della forma (scheda Forme fattura).
## Scrive docs/report-simulazione.md. Non cambia nessun numero: misura e riporta.

const REPORT := "res://docs/report-simulazione.md"
const ETA: Array[StringName] = [Id.GIOVINEZZA, Id.ETA_ADULTA, Id.VECCHIAIA]
const STRATEGIE := {
	GiocatoreAutomatico.Strategia.RAGIONEVOLE: "ragionevole",
	GiocatoreAutomatico.Strategia.PRUDENTE: "prudente",
	GiocatoreAutomatico.Strategia.AGGRESSIVA: "aggressiva",
}


func _initialize() -> void:
	var argomenti := OS.get_cmdline_user_args()
	var quanti := int(_argomento(argomenti, "--combattimenti", "1000"))
	var caricatore := Caricatore.new()
	var catalogo := caricatore.carica()
	if catalogo == null:
		for e in caricatore.errori:
			printerr(e)
		quit(1)
		return
	var proposta := _argomento(argomenti, "--proposta", "")
	var percorso_report := _argomento(argomenti, "--report", REPORT if proposta == "" else "res://docs/report-proposta.md")
	if proposta != "":
		Simulatore.applica_proposta(catalogo, JSON.parse_string(FileAccess.get_file_as_string(proposta)))
	var regole := RegoleCombattimento.da_bilanciamento(catalogo.bilanciamento)
	var nemici := []
	for id in catalogo.nemici:
		if catalogo.nemici[id].get("livello") == Id.NORMALE:
			nemici.append(id)
	var inizio := Time.get_ticks_msec()
	var risultati := {}
	for forma in Id.FORME:
		var mazzo := Simulatore.mazzo_riferimento(catalogo, Simulatore.fase_della_forma(catalogo, forma))
		for eta in ETA:
			for strategia in STRATEGIE:
				for id in nemici:
					risultati[[forma, eta, strategia, id]] = Simulatore.simula(catalogo, regole, mazzo, id, eta, forma, strategia, quanti)
		print("forma %s: fatto" % forma)
	var secondi := (Time.get_ticks_msec() - inizio) / 1000.0
	var testo := report(catalogo, nemici, risultati, quanti)
	testo = testo.replace("{SECONDI}", "%.0f" % secondi)
	if proposta != "":
		testo = testo.replace("## Come\n", "## Come\n- **Con la proposta di `%s`**, applicata solo in memoria: foglio e dati non sono cambiati.\n" % proposta)
	var f := FileAccess.open(percorso_report, FileAccess.WRITE)
	f.store_string(testo)
	f.close()
	print("Report scritto in %s (%.0f s)" % [percorso_report, secondi])
	quit(0)


func report(catalogo: Catalogo, nemici: Array, risultati: Dictionary, quanti: int) -> String:
	var b := catalogo.bilanciamento
	var r := PackedStringArray()
	r.append("# Report della simulazione di bilanciamento")
	r.append("")
	r.append("Generato da `strumenti/simula.gd` il %s. **Nessun numero è stato corretto: il report misura e basta.**" % Time.get_date_string_from_system())
	r.append("")
	r.append("## Come")
	r.append("- D65: ogni forma della fattura si misura contro il **mazzo di riferimento della sua fase** (scheda Mazzi di riferimento) e i suoi **obiettivi** (scheda Forme fattura, colonne F-J). Carte con livello: evoluzione \"Più forte\" una o due volte; contano come ereditate (per le Radici).")
	r.append("- %d combattimenti per riga (semi da 1 a %d), un nemico normale alla volta, vita piena a inizio combattimento, casa %d in tutte le età." % [quanti, quanti, int(b["casa"]["vita"])])
	r.append("- Strategie (`core/simulazione/giocatore_automatico.gd`): **ragionevole** = prima le carte che preparano (pesca, Radici); si difende solo da un colpo che supera il %d%% della vita massima o che sarebbe letale, e solo finché resta sopra quella soglia; se può uccidere il nemico in questo turno attacca. **Prudente** = blocca ogni danno annunciato prima di attaccare. **Aggressiva** = non si difende mai prima di attaccare." % int(GiocatoreAutomatico.SOGLIA_DIFESA * 100))
	r.append("- Gli obiettivi si confrontano con la strategia **ragionevole** (D65: \"con un gioco ragionevole\"). Δ = distanza dall'intervallo obiettivo (0 = dentro; turni in turni, vita in punti percentuali). Un obiettivo di turni esatto (\"4\") vale ±0,5.")
	r.append("- Tempo di calcolo: {SECONDI} s.")
	r.append("")
	r.append("## Riepilogo (strategia ragionevole, media sulle tre età)")
	r.append("")
	r.append("| Forma | Mazzo | Obiettivo turni | Obiettivo vita persa | Nemico | Turni | Vita persa | Δ turni | Δ vita | Dentro? |")
	r.append("| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |")
	for forma in Id.FORME:
		var o := Simulatore.obiettivi(catalogo, forma)
		for id in nemici:
			var turni := 0.0
			var vita := 0.0
			for eta in ETA:
				var t: Dictionary = risultati[[forma, eta, GiocatoreAutomatico.Strategia.RAGIONEVOLE, id]]
				turni += Simulatore.media(t["turni"]) / ETA.size()
				vita += Simulatore.media(t["vita_persa"]) * 100.0 / ETA.size()
			var dt := Simulatore.distanza(turni, o["turni_min"], o["turni_max"])
			var dv := Simulatore.distanza(vita, o["vita_persa_min"] * 100.0, o["vita_persa_max"] * 100.0)
			r.append("| %s | %s | %s | %s | %s | %.2f | %.1f%% | %s | %s | %s |" % [forma, Simulatore.fase_della_forma(catalogo, forma),
				_intervallo(o["turni_min"], o["turni_max"], ""), _intervallo(o["vita_persa_min"] * 100, o["vita_persa_max"] * 100, "%"),
				id, turni, vita, _delta(dt), _delta(dv), "sì" if dt == 0.0 and dv == 0.0 else "no"])
	for forma in Id.FORME:
		var o := Simulatore.obiettivi(catalogo, forma)
		var fase := Simulatore.fase_della_forma(catalogo, forma)
		var mazzo := Simulatore.mazzo_riferimento(catalogo, fase)
		r.append("")
		r.append("## Forma %s — mazzo \"%s\" (generazione %d, %d carte)" % [forma, fase, int(b["mazzi_riferimento"][fase]["generazione"]), mazzo.size()])
		r.append("")
		r.append("Obiettivi: %s turni, %s di vita persa." % [_intervallo(o["turni_min"], o["turni_max"], ""), _intervallo(o["vita_persa_min"] * 100, o["vita_persa_max"] * 100, "%")])
		r.append("")
		var divorata := forma == Id.DIVORATA
		r.append("| Età (vita) | Strategia | Nemico | Vittorie | Turni medi | Vita persa media | Vita persa 90° perc. | Casa persa | Fattura a fine | Δ turni | Δ vita |" + (" Colpo potenziato (medio / max) | Sconfitte per il colpo potenziato |" if divorata else ""))
		r.append("| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" + (" --- | --- |" if divorata else ""))
		for eta in ETA:
			for strategia in STRATEGIE:
				for id in nemici:
					var t: Dictionary = risultati[[forma, eta, strategia, id]]
					var turni := Simulatore.media(t["turni"])
					var vita := Simulatore.media(t["vita_persa"]) * 100.0
					var riga := "| %s (%d) | %s | %s | %.1f%% | %.2f | %.1f%% | %.1f%% | %.1f | %.2f | %s | %s |" % [
						str(eta).replace("_", " "), t["vita"], STRATEGIE[strategia], id, 100.0 * t["vittorie"] / quanti,
						turni, vita, Simulatore.percentile(t["vita_persa"], 0.9) * 100.0, Simulatore.media(t["casa_persa"]),
						Simulatore.media(t["fattura"]),
						_delta(Simulatore.distanza(turni, o["turni_min"], o["turni_max"])),
						_delta(Simulatore.distanza(vita, o["vita_persa_min"] * 100.0, o["vita_persa_max"] * 100.0))]
					if divorata:
						var colpi: Array = t["colpi_potenziati"]
						riga += " %s | %.1f%% |" % ["–" if colpi.is_empty() else "%.1f / %d" % [Simulatore.media(colpi), int(colpi.max())],
							100.0 * t["uccisi_dal_potenziato"] / quanti]
					r.append(riga)
	r.append("")
	r.append("## Osservazioni")
	r.append("(da scrivere a mano dopo l'esecuzione)")
	return "\n".join(r) + "\n"


func _intervallo(minimo: float, massimo: float, unita: String) -> String:
	if is_equal_approx(minimo, massimo):
		return "%s%s" % [_numero(minimo), unita]
	return "%s-%s%s" % [_numero(minimo), _numero(massimo), unita]


func _numero(x: float) -> String:
	return str(int(x)) if is_equal_approx(x, roundf(x)) else "%.1f" % x


func _delta(d: float) -> String:
	return "0" if d == 0.0 else "%+.1f" % d


func _argomento(argomenti: PackedStringArray, nome: String, predefinito: String) -> String:
	var i := argomenti.find(nome)
	return argomenti[i + 1] if i >= 0 and i + 1 < argomenti.size() else predefinito
