extends SceneTree
## Simulazione di bilanciamento (vedi docs/COMANDI.md):
##   godot --headless --path . -s res://strumenti/simula.gd [-- --combattimenti 1000 --casata masciare --turni-obiettivo 4]
## --turni-obiettivo: durata con cui confrontare i risultati (predefinita: l'ancora del foglio, per il mazzo medio).
## Gioca molti combattimenti con il mazzo base di una casata contro ogni nemico normale,
## con la strategia semplice di GiocatoreAutomatico, e scrive docs/report-simulazione.md.
## Non cambia nessun numero: misura e riporta.

const REPORT := "res://docs/report-simulazione.md"
const ETA: Array[StringName] = [Id.GIOVINEZZA, Id.ETA_ADULTA]
## Scenario di riferimento del report (età adulta, strategia che non si difende).
const SENZA_DIFESA := &"senza_difesa"
## Età dello scenario con la forma divorata (anche la vecchiaia: è la vita più bassa).
const ETA_DIVORATA: Array[StringName] = [Id.GIOVINEZZA, Id.ETA_ADULTA, Id.VECCHIAIA]


func _initialize() -> void:
	var argomenti := OS.get_cmdline_user_args()
	var quanti := int(_argomento(argomenti, "--combattimenti", "1000"))
	var casata := _argomento(argomenti, "--casata", "masciare")
	var turni_obiettivo := _argomento(argomenti, "--turni-obiettivo", "")
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
		if catalogo.nemici[id].get("livello") == Id.NORMALE:
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
	risultati[SENZA_DIFESA] = {}
	for id in nemici:
		risultati[SENZA_DIFESA][id] = _simula(catalogo, regole, mazzo, id, Id.ETA_ADULTA, quanti, false)
	# Forma divorata: tutte le età, con le due strategie
	var divorata := {}
	for eta in ETA_DIVORATA:
		for difende in [true, false]:
			for id in nemici:
				divorata[[eta, difende, id]] = _simula(catalogo, regole, mazzo, id, eta, quanti, difende, Id.DIVORATA)
		print("divorata / %s: fatto" % eta)
	var secondi := (Time.get_ticks_msec() - inizio) / 1000.0
	_scrivi_report(b, casata, mazzo.size(), nemici, risultati, quanti, secondi, turni_obiettivo)
	_aggiungi_divorata(nemici, divorata, quanti)
	print("Report scritto in %s (%.1f s)" % [REPORT, secondi])
	quit(0)


func _simula(catalogo: Catalogo, regole: RegoleCombattimento, mazzo: Array, nemico: String, eta: StringName, quanti: int, difende: bool = true, forma: StringName = Id.BASE) -> Dictionary:
	var b := catalogo.bilanciamento
	var dati_eta: Dictionary = b["eta"][eta]
	var vita := int(dati_eta["vita"])
	var potenziate: Array = catalogo.nemici[nemico].get("forme", {}).get(forma, {}).get("intenzioni_potenziate", []) if forma != Id.BASE else []
	var t := {"vittorie": 0, "turni": [], "turni_vittorie": [], "vita_persa": [], "casa_persa": [], "tratti": 0, "fattura": [], "interrotti": 0,
		"vita": vita, "colpi_potenziati": [], "uccisi_dal_potenziato": 0}
	for seme in range(1, quanti + 1):
		var c := Combattimento.new(catalogo, {
			"seme": seme, "mazzo": mazzo, "nemici": [{"id": nemico, "forma": forma}],
			"giocatore": {"vita": vita, "vita_max": vita},
			"casa": {"vita": int(b["casa"]["vita"])},
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
		t["casa_persa"].append(int(b["casa"]["vita"]) - int(r["casa_vita"]))
		t["tratti"] += int(r["tratti_negativi"])
		t["fattura"].append(int(r["stati_persistenti"].get("fattura", 0)))
		_colpi_potenziati(c, potenziate, t)
	return t


## Dal registro: danno subito dal giocatore a ogni esecuzione di un'intenzione potenziata,
## e se quel colpo ha chiuso il combattimento con la sconfitta.
func _colpi_potenziati(c: Combattimento, potenziate: Array, t: Dictionary) -> void:
	if potenziate.is_empty():
		return
	var in_corso := false
	var subito := 0
	for v in c.registro.voci:
		if v["tipo"] == Id.R_INTENZIONE_ESEGUITA:
			if in_corso:
				t["colpi_potenziati"].append(subito)
			in_corso = potenziate.has(str(v.get("intenzione", "")))
			subito = 0
		elif in_corso and v["tipo"] == Id.DANNO and v.get("a") == Id.GIOCATORE:
			subito += int(v["subito"])
		elif in_corso and v["tipo"] == Id.FINE_COMBATTIMENTO and v.get("esito") == "sconfitta":
			t["uccisi_dal_potenziato"] += 1
		elif in_corso and v["tipo"] in [Id.R_INTENZIONE, Id.INIZIO_TURNO]:
			t["colpi_potenziati"].append(subito)
			in_corso = false
	if in_corso:
		t["colpi_potenziati"].append(subito)


func _scrivi_report(b: Dictionary, casata: String, carte: int, nemici: Array, risultati: Dictionary, quanti: int, secondi: float, turni_argomento: String) -> void:
	var a: Dictionary = b["ancore"]
	var turni_obiettivo := float(a["turni_normale"]) if turni_argomento == "" else float(turni_argomento)
	var min_vita := float(a["vita_persa_min"]) * 100.0
	var max_vita := float(a["vita_persa_max"]) * 100.0
	var r := PackedStringArray()
	r.append("# Report della simulazione di bilanciamento")
	r.append("")
	r.append("Generato da `strumenti/simula.gd` il %s. **Nessun numero è stato corretto: il report misura e basta.**" % Time.get_date_string_from_system())
	r.append("")
	r.append("## Come")
	r.append("- Mazzo base della casata **%s** (%d carte), %d combattimenti per nemico e per età (semi da 1 a %d), forma base dei nemici." % [casata, carte, quanti, quanti])
	r.append("- Età: vita e carte in mano dal foglio (scheda Età); casa (%d) in tutte le età; vita piena a inizio combattimento." % int(b["casa"]["vita"]))
	r.append("- Strategia (`core/simulazione/giocatore_automatico.gd`): se un'intenzione visibile farà danni a te o alla casa oltre il blocco, gioca la carta che blocca di più (prima te, poi la casa); altrimenti la carta che fa più danni, sul nemico con meno vita; poi il resto.")
	r.append("- Obiettivo di confronto: **%s turni** per un combattimento normale (ancora del foglio: %d, per un mazzo medio tra le casate) e **%d-%d%%** di vita persa (scheda Ancore)." % [str(turni_obiettivo), int(a["turni_normale"]), int(min_vita), int(max_vita)])
	r.append("- Tempo di calcolo: %.1f s." % secondi)
	var titoli := {Id.GIOVINEZZA: "Giovinezza", Id.ETA_ADULTA: "Età adulta",
		SENZA_DIFESA: "Riferimento: età adulta, strategia che attacca soltanto"}
	for eta in ETA + [SENZA_DIFESA]:
		r.append("")
		r.append("## " + str(titoli[eta]))
		r.append("")
		r.append("| Nemico | Vittorie | Turni medi | Turni (min–max) | Vita persa media | Vita persa (10°–90° perc.) | Rispetto all'obiettivo | Casa persa media | Tratti negativi | Fattura a fine combattimento |")
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
				", ".join(giudizio), _media(t["casa_persa"]), 100.0 * t["tratti"] / quanti, _media(t["fattura"])])
	r.append("")
	r.append("Legenda: \"turni nella norma\" = media entro ±0,5 dall'obiettivo; \"vita nella norma\" = media nella fascia delle ancore. Casa persa: punti di vita della casa (35) persi in media.")
	r.append("")
	r.append("## Osservazioni")
	r.append("(scritte a mano dopo l'esecuzione, vedi sotto)")
	var f := FileAccess.open(REPORT, FileAccess.WRITE)
	f.store_string("\n".join(r) + "\n")
	f.close()


func _aggiungi_divorata(nemici: Array, divorata: Dictionary, quanti: int) -> void:
	var r := PackedStringArray()
	r.append("")
	r.append("## Forma divorata")
	r.append("")
	r.append("Tutti i nemici in forma divorata (vita × 1,6, danni × 1,3, intenzione potenziata × 1,5 in più), stesso mazzo base. \"Colpo potenziato\": danno subito dal giocatore quando il nemico esegue la sua intenzione potenziata (dopo il blocco). La Janara potenzia l'assalto alla casa, che non colpisce il giocatore.")
	r.append("")
	r.append("| Età (vita) | Strategia | Nemico | Vittorie | Turni medi | Vita persa media | Colpi potenziati subiti | Danno medio del colpo potenziato | Colpo potenziato più forte | Sconfitte per il colpo potenziato |")
	r.append("| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |")
	for eta in ETA_DIVORATA:
		for difende in [true, false]:
			for id in nemici:
				var t: Dictionary = divorata[[eta, difende, id]]
				var colpi: Array = t["colpi_potenziati"]
				r.append("| %s (%d) | %s | %s | %.1f%% | %.2f | %.1f%% | %d | %s | %s | %.1f%% |" % [
					str(eta).replace("_", " "), t["vita"], "difende" if difende else "solo attacco", id,
					100.0 * t["vittorie"] / quanti, _media(t["turni"]), _media(t["vita_persa"]) * 100.0,
					colpi.size(), "%.1f" % _media(colpi) if not colpi.is_empty() else "–",
					str(_max(colpi)) if not colpi.is_empty() else "–", 100.0 * t["uccisi_dal_potenziato"] / quanti])
	var testo := FileAccess.get_file_as_string(REPORT)
	testo = testo.replace("\n## Osservazioni", "\n".join(r) + "\n\n## Osservazioni")
	var f := FileAccess.open(REPORT, FileAccess.WRITE)
	f.store_string(testo)
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
