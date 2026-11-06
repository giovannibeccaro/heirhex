class_name GestoreStati
extends RefCounted
## Regole generiche degli stati (i singoli stati sono dati in data/manuali/stati.json):
## - tipo "intensita": le cariche si sommano e restano per il combattimento;
## - tipo "durata": cala di 1 alla fine del turno di chi lo porta;
## - tipo "soglia": quando le cariche arrivano alla soglia scatta l'aggancio "soglia_raggiunta".
## - "agganci": effetti eseguiti quando accade un evento a chi porta lo stato;
## - "modificatori": modificatori attivi finché lo stato c'è ("per_carica": valore × cariche).


## Fa reagire gli stati di chi è interessato dall'evento.
static func reagisci(c: Combattimento, evento: StringName, dati: Dictionary) -> void:
	for chi in _interessati(c, dati):
		for id_stato in chi.stati.keys():
			if not chi.ha_stato(id_stato) or not chi.e_vivo():
				continue
			if evento == Id.SOGLIA_RAGGIUNTA and StringName(dati.get("stato", "")) != StringName(id_stato):
				continue
			var definizione := c.stato.catalogo.stato(id_stato)
			for aggancio in definizione.get("agganci", []):
				if StringName(aggancio.get("quando", "")) == evento:
					c.registro.aggiungi(c.stato.turno, Id.R_AGGANCIO_STATO, {"stato": id_stato, "evento": evento, "chi": c.nome_tecnico(chi)})
					Mattoncini.esegui_lista(c, aggancio.get("effetti", []), ContestoEffetto.new(chi))
		if evento == Id.FINE_TURNO:
			_scala_durate(c, chi)


## Dopo che sono state aggiunte cariche: controlla la soglia.
static func controlla_soglia(c: Combattimento, chi: Combattente, id_stato: StringName) -> void:
	var definizione := c.stato.catalogo.stato(id_stato)
	if StringName(definizione.get("tipo", "")) != Id.SOGLIA:
		return
	if chi.cariche(id_stato) >= int(definizione.get("soglia", 0)):
		c.emetti(Id.SOGLIA_RAGGIUNTA, {"chi": chi, "stato": id_stato})


## Modificatori portati dagli stati di tutti i combattenti.
static func modificatori(c: Combattimento) -> Array[Modificatore]:
	var risultato: Array[Modificatore] = []
	var s := c.stato
	var combattenti: Array[Combattente] = [s.giocatore, s.casa]
	combattenti.append_array(s.nemici)
	for chi in combattenti:
		if chi.stati.is_empty() or not chi.e_vivo():
			continue
		for id_stato in chi.stati:
			for d in s.catalogo.stato(id_stato).get("modificatori", []):
				var m := Modificatore.da_dizionario(d)
				if bool(d.get("per_carica", false)):
					m.valore *= chi.cariche(id_stato)
				m.fonte = "stato." + str(id_stato)
				# "se" = chi porta lo stato
				if m.bersaglio_tipo == Id.SE:
					m.bersaglio_tipo = c.tipo_di(chi)
					if chi is Nemico:
						m.filtro = {Id.UID: (chi as Nemico).uid}
				# Le carte appartengono al giocatore: solo i suoi stati le modificano
				if m.bersaglio_tipo == Id.CARTA and chi != s.giocatore:
					continue
				risultato.append(m)
	return risultato


static func _scala_durate(c: Combattimento, chi: Combattente) -> void:
	for id_stato in chi.stati.keys():
		if StringName(c.stato.catalogo.stato(id_stato).get("tipo", "")) == Id.DURATA:
			c.rimuovi_stato(chi, id_stato, 1)


static func _interessati(c: Combattimento, dati: Dictionary) -> Array[Combattente]:
	var risultato: Array[Combattente] = []
	if dati.get("chi") is Combattente:
		risultato.append(dati["chi"])
	else:
		risultato.append(c.stato.giocatore)
		risultato.append_array(c.stato.nemici)
	return risultato
