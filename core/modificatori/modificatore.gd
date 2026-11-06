class_name Modificatore
extends RefCounted
## Una regola che cambia una proprietà: { fonte, bersaglio, proprieta, operazione, valore, durata }.
## Stessa forma per età, annate, amuleti, casate, stati, forme della fattura (schemi-dati.md, sezione 5).

const DURATE := ["turno", "combattimento", "vita", "stirpe"]
const OPERAZIONI := ["somma", "moltiplica", "imposta"]

var id: String = ""
var fonte: String = ""
var bersaglio_tipo: String = ""     ## giocatore, casa, carta, nemico, ...
var filtro: Dictionary = {}
var proprieta: String = ""
var operazione: String = "somma"
var valore: float = 0.0
var durata: String = "combattimento"


static func da_dizionario(d: Dictionary) -> Modificatore:
	var m := Modificatore.new()
	m.id = str(d.get("id", ""))
	m.fonte = str(d.get("fonte", ""))
	var b: Dictionary = d.get("bersaglio", {})
	m.bersaglio_tipo = str(b.get("tipo", ""))
	m.filtro = b.get("filtro", {})
	m.proprieta = str(d.get("proprieta", ""))
	m.operazione = str(d.get("operazione", "somma"))
	m.valore = float(d.get("valore", 0))
	m.durata = str(d.get("durata", "combattimento"))
	assert(m.operazione in OPERAZIONI, "Operazione sconosciuta: " + m.operazione)
	assert(m.durata in DURATE, "Durata sconosciuta: " + m.durata)
	return m


## Copia con un valore diverso (es. moltiplicato per le cariche di uno stato).
func con_valore(nuovo: float) -> Modificatore:
	var m := Modificatore.new()
	m.id = id
	m.fonte = fonte
	m.bersaglio_tipo = bersaglio_tipo
	m.filtro = filtro
	m.proprieta = proprieta
	m.operazione = operazione
	m.valore = nuovo
	m.durata = durata
	return m


func si_applica(p_proprieta: String, tipo_oggetto: String, oggetto: Variant) -> bool:
	if proprieta != p_proprieta or bersaglio_tipo != tipo_oggetto:
		return false
	for chiave in filtro:
		if not _filtro_ok(str(chiave), filtro[chiave], oggetto):
			return false
	return true


## Un filtro sconosciuto non corrisponde mai (il validatore lo segnala).
func _filtro_ok(chiave: String, atteso: Variant, oggetto: Variant) -> bool:
	if oggetto is Carta:
		var c := oggetto as Carta
		match chiave:
			"ereditata": return c.ereditata == bool(atteso)
			"uid": return c.uid == int(atteso)
			"id": return c.id == str(atteso)
			"tag": return c.tag().has(atteso)
			"rarita", "tipo", "famiglia", "casata": return str(c.dati.get(chiave, "")) == str(atteso)
	elif oggetto is Nemico:
		var n := oggetto as Nemico
		match chiave:
			"uid": return n.uid == int(atteso)
			"id": return n.id == str(atteso)
			"ruolo", "livello": return str(n.dati.get(chiave, "")) == str(atteso)
	return false
