class_name Modificatore
extends RefCounted
## Una regola che cambia una proprietà: { fonte, bersaglio {tipo, filtro}, proprieta, operazione, valore, durata }.
## Stessa forma per età, annate, amuleti, casate, stati, forme della fattura (schemi-dati.md, sezione 5).

var id: String = ""
var fonte: String = ""
var bersaglio_tipo: StringName = &""   ## Id.TIPI_OGGETTO
var filtro: Dictionary = {}            ## Id.FILTRI -> valore atteso
var proprieta: StringName = &""        ## Id.PROPRIETA
var operazione: StringName = Id.SOMMA  ## Id.OPERAZIONI
var valore: float = 0.0
var durata: StringName = Id.COMBATTIMENTO  ## Id.DURATE


static func crea(p_tipo: StringName, p_proprieta: StringName, p_operazione: StringName, p_valore: float,
		p_durata: StringName = Id.COMBATTIMENTO, p_filtro: Dictionary = {}, p_fonte: String = "") -> Modificatore:
	assert(p_operazione in Id.OPERAZIONI, "Operazione sconosciuta: " + p_operazione)
	assert(p_durata in Id.DURATE, "Durata sconosciuta: " + p_durata)
	var m := Modificatore.new()
	m.bersaglio_tipo = p_tipo
	m.proprieta = p_proprieta
	m.operazione = p_operazione
	m.valore = p_valore
	m.durata = p_durata
	m.fonte = p_fonte
	for chiave in p_filtro:
		m.filtro[StringName(chiave)] = p_filtro[chiave]
	return m


static func da_dizionario(d: Dictionary) -> Modificatore:
	var b: Dictionary = d.get("bersaglio", {})
	var m := crea(StringName(b.get("tipo", "")), StringName(d.get("proprieta", "")),
		StringName(d.get("operazione", Id.SOMMA)), float(d.get("valore", 0)),
		StringName(d.get("durata", Id.COMBATTIMENTO)), b.get("filtro", {}), str(d.get("fonte", "")))
	m.id = str(d.get("id", ""))
	return m


## Copia con un valore diverso (es. moltiplicato per le cariche di uno stato).
func con_valore(nuovo: float) -> Modificatore:
	var m := crea(bersaglio_tipo, proprieta, operazione, nuovo, durata, filtro, fonte)
	m.id = id
	return m


func si_applica(p_proprieta: StringName, tipo_oggetto: StringName, oggetto: Variant) -> bool:
	if proprieta != p_proprieta or bersaglio_tipo != tipo_oggetto:
		return false
	for chiave in filtro:
		if not _filtro_ok(chiave, filtro[chiave], oggetto):
			return false
	return true


## Un filtro sconosciuto non corrisponde mai (il caricatore lo rifiuta prima).
func _filtro_ok(chiave: StringName, atteso: Variant, oggetto: Variant) -> bool:
	if oggetto is Carta:
		var c := oggetto as Carta
		match chiave:
			Id.EREDITATA: return c.ereditata == bool(atteso)
			Id.UID: return c.uid == int(atteso)
			Id.ID: return c.id == str(atteso)
			Id.TAG: return c.tag().has(atteso)
			Id.RARITA, Id.TIPO, Id.FAMIGLIA, Id.CASATA: return str(c.dati.get(chiave, "")) == str(atteso)
	elif oggetto is Nemico:
		var n := oggetto as Nemico
		match chiave:
			Id.UID: return n.uid == int(atteso)
			Id.ID: return n.id == str(atteso)
			Id.RUOLO, Id.LIVELLO: return str(n.dati.get(chiave, "")) == str(atteso)
	return false
