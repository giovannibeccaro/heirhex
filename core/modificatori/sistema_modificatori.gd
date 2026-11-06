class_name SistemaModificatori
extends RefCounted
## L'unico sistema di modificatori. Ordine di calcolo fisso: prima tutte le somme,
## poi tutte le moltiplicazioni, poi "imposta" (se più d'una, vale l'ultima aggiunta).

var lista: Array[Modificatore] = []


func aggiungi(m: Modificatore) -> void:
	lista.append(m)


func aggiungi_da_dizionario(d: Dictionary) -> Modificatore:
	var m := Modificatore.da_dizionario(d)
	lista.append(m)
	return m


func rimuovi_fonte(fonte: String) -> void:
	lista = lista.filter(func(m: Modificatore) -> bool: return m.fonte != fonte)


## Toglie i modificatori che scadono quando finisce un turno, un combattimento, una vita…
## Le durate sono ordinate: la fine di un combattimento è anche la fine del turno.
func scadenza(finito: String) -> void:
	var livello := Modificatore.DURATE.find(finito)
	lista = lista.filter(func(m: Modificatore) -> bool: return Modificatore.DURATE.find(m.durata) > livello)


func attivi(proprieta: String, tipo_oggetto: String, oggetto: Variant, extra: Array[Modificatore] = []) -> Array[Modificatore]:
	var risultato: Array[Modificatore] = []
	for m in lista + extra:
		if m.si_applica(proprieta, tipo_oggetto, oggetto):
			risultato.append(m)
	return risultato


func calcola(base: float, proprieta: String, tipo_oggetto: String, oggetto: Variant, extra: Array[Modificatore] = []) -> float:
	return applica(base, attivi(proprieta, tipo_oggetto, oggetto, extra))


static func applica(base: float, mods: Array[Modificatore]) -> float:
	var risultato := base
	for m in mods:
		if m.operazione == "somma":
			risultato += m.valore
	for m in mods:
		if m.operazione == "moltiplica":
			risultato *= m.valore
	for m in mods:
		if m.operazione == "imposta":
			risultato = m.valore
	return risultato
