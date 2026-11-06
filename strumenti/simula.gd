extends SceneTree
## Simulazione di bilanciamento (vedi docs/COMANDI.md):
##   godot --headless --path . -s res://strumenti/simula.gd [-- --combattimenti 1000 --casata masciare]
## Gioca molti combattimenti con il mazzo base di una casata contro ogni nemico normale,
## con la strategia semplice di GiocatoreAutomatico, e scrive docs/report-simulazione.md.
## Non cambia nessun numero: misura e riporta.

const REPORT := "res://docs/report-simulazione.md"
const ETA := ["giovinezza", "eta_adulta"]


func _initialize() -> void:
	var argomenti := OS.get_cmdline_user_args()
	var quanti := int(_argomento(argomenti, "--combattimenti", "1000"))
	var casata := _argomento(argomenti, "--casata", "masciare")
	var caricatore := Caricatore.new()
	var catalogo := caricatore.carica()
	if catalogo == null:
		for e in caricatore.errori:
			printerr(e)
		quit(1)
		return
	var b := catalogo.bilanciamento
	var mazzo := []
	for voce in b["mazzi_base"][casata]:
		for i in int(voce["copie"]):
			mazzo.append(voce["carta"])
	var nemici := []
	for id in catalogo.nemici:
		if str(catalogo.nemici[id].get("livello", "")) == "normale":
			nemici.append(id)
	var regole := RegoleCombattimento.da_bilanciamento(b)
	var inizio := Time.get_ticks_msec()
	var risultati := {}
	for eta in ETA:
		risultati[eta] = {}
		for id in nemici:
			risultati[eta][id] = _simula(catalogo, regole, mazzo, id, eta, quanti)
			print("%s / %s: fatto" % [eta, id])
	# Riferimento: stessa età adulta, ma la strategia non si difende mai prima di attaccare
	risultati["senza_difesa"] = {}
	for id in nemici:
		risultati["senza_difesa"][id] = _simula(catalogo, regole, mazzo, id, "eta_adulta", quanti, false)
	var secondi := (Time.get_ticks_msec() - inizio) / 1000.0
	_scrivi_report(b, casata, mazzo.size(), nemici, risultati, quanti, secondi)
	print("Report scritto in %s (%.1f s)" % [REPORT, secondi])
	quit(0)


func _simula(catalogo: Catalogo, regole: RegoleCombattimento, mazzo: Array, nemico: String, eta: String, quanti: int, difende: bool = true) -> Dictionary:
	var b := catalogo.bilanciamento
	var dati_eta: Dictionary = b["eta"][eta]
	var culla_attiva := eta != "giovinezza"
	var vita := int(dati_eta["vita"])
	var t := {"vittorie": 0, "turni": [], "turni_vittorie": [], "vita_persa": [], "culla_persa": [], "tratti": 0, "fattura": [], "interrotti": 0}
	for seme in range(1, quanti + 1):
		var c := Combattimento.new(catalogo, {
			"seme": seme, "mazzo": mazzo, "nemici": [nemico],
			"giocatore": {"vita": vita, "vita_max": vita},
			"culla": {"vita": int(b["culla"]["vita"]), "attiva": culla_attiva},
			"mano": int(dati_eta["mano"]),
		}, regole)
		GiocatoreAutomatico.gioca_combattimento(c, 50, difende)
		var r := c.riepilogo()
		if not c.finito():
			t["interrotti"] += 1
		if r["esito"] == "vittoria":
			t["vittorie"] += 1
			t["turni_vittorie"].append(r["turni"])
		t["turni"].append(r["turni"])
		t["vita_persa"].append(float(r["vita_persa"]) / float(r["vita_max"]))
		t["culla_persa"].append(int(b["culla"]["vita"]) - int(r["culla_vita"]) if culla_attiva else 0)
		t["tratti"] += int(r["tratti_negativi"])
		t["fattura"].append(int(r["stati_persistenti"].get("fattura", 0)))
	return t


func _scrivi_report(b: Dictionary, casata: String, carte: int, nemici: Array, risultati: Dictionary, quanti: int, secondi: float) -> void:
	var a: Dictionary = b["ancore"]
	var turni_obiettivo := float(a["turni_normale"])
	var min_vita := float(a["vita_persa_min"]) * 100.0
	var max_vita := float(a["vita_persa_max"]) * 100.0
	var r := PackedStringArray()
	r.append("# Report della simulazione di bilanciamento")
	r.append("")
	r.append("Generato da `strumenti/simula.gd` il %s. **Nessun numero è stato corretto: il report misura e basta.**" % Time.get_date_string_from_system())
	r.append("")
	r.append("## Come")
	r.append("- Mazzo base della casata **%s** (%d carte), %d combattimenti per nemico e per età (semi da 1 a %d), forma base dei nemici." % [casata, carte, quanti, quanti])
	r.append("- Età: vita e carte in mano dal foglio (scheda Età); culla (%d) attiva dall'età adulta; vita piena a inizio combattimento." % int(b["culla"]["vita"]))
	r.append("- Strategia (`core/simulazione/giocatore_automatico.gd`): se un'intenzione visibile farà danni a te o alla culla oltre il blocco, gioca la carta che blocca di più (prima te, poi la culla); altrimenti la carta che fa più danni, sul nemico con meno vita; poi il resto.")
	r.append("- Ancore di confronto (scheda Ancore): **%d turni** per un combattimento normale, **%d-%d%%** di vita persa." % [int(turni_obiettivo), int(min_vita), int(max_vita)])
	r.append("- Tempo di calcolo: %.1f s." % secondi)
	var titoli := {"giovinezza": "Giovinezza (vita 100, mano 4, senza culla)", "eta_adulta": "Età adulta (vita 85, mano 5, culla)",
		"senza_difesa": "Riferimento: età adulta, strategia che attacca soltanto"}
	for eta in ETA + ["senza_difesa"]:
		r.append("")
		r.append("## " + str(titoli[eta]))
		r.append("")
		r.append("| Nemico | Vittorie | Turni medi | Turni (min–max) | Vita persa media | Vita persa (10°–90° perc.) | Rispetto alle ancore | Culla persa media | Tratti negativi | Fattura a fine combattimento |")
		r.append("| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |")
		for id in nemici:
			var t: Dictionary = risultati[eta][id]
			var turni_medi := _media(t["turni"])
			var vita_media := _media(t["vita_persa"]) * 100.0
			var giudizio := PackedStringArray()
			giudizio.append("turni " + _confronto(turni_medi, turni_obiettivo - 0.5, turni_obiettivo + 0.5))
			giudizio.append("vita " + _confronto(vita_media, min_vita, max_vita))
			r.append("| %s | %.1f%% | %.2f | %d–%d | %.1f%% | %.1f%%–%.1f%% | %s | %.1f | %.1f%% | %.2f |" % [
				id, 100.0 * t["vittorie"] / quanti, turni_medi, _min(t["turni"]), _max(t["turni"]),
				vita_media, _percentile(t["vita_persa"], 0.1) * 100.0, _percentile(t["vita_persa"], 0.9) * 100.0,
				", ".join(giudizio), _media(t["culla_persa"]), 100.0 * t["tratti"] / quanti, _media(t["fattura"])])
	r.append("")
	r.append("Legenda: \"turni nella norma\" = media entro ±0,5 dall'ancora; \"vita nella norma\" = media nella fascia delle ancore.")
	r.append("")
	r.append("## Osservazioni")
	r.append("(scritte a mano dopo l'esecuzione, vedi sotto)")
	var f := FileAccess.open(REPORT, FileAccess.WRITE)
	f.store_string("\n".join(r) + "\n")
	f.close()


func _confronto(valore: float, minimo: float, massimo: float) -> String:
	if valore < minimo:
		return "sotto"
	if valore > massimo:
		return "sopra"
	return "nella norma"


func _media(valori: Array) -> float:
	if valori.is_empty():
		return 0.0
	var somma := 0.0
	for v in valori:
		somma += float(v)
	return somma / valori.size()


func _min(valori: Array) -> int:
	return int(valori.min()) if not valori.is_empty() else 0


func _max(valori: Array) -> int:
	return int(valori.max()) if not valori.is_empty() else 0


func _percentile(valori: Array, p: float) -> float:
	if valori.is_empty():
		return 0.0
	var ordinati := valori.duplicate()
	ordinati.sort()
	return float(ordinati[clampi(int(p * (ordinati.size() - 1)), 0, ordinati.size() - 1)])


func _argomento(argomenti: PackedStringArray, nome: String, predefinito: String) -> String:
	var i := argomenti.find(nome)
	return argomenti[i + 1] if i >= 0 and i + 1 < argomenti.size() else predefinito
