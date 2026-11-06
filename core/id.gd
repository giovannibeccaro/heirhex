class_name Id
extends RefCounted
## Tutti gli identificatori interni del motore, definiti una sola volta (CLAUDE.md, Convenzioni).
## Nei JSON restano stringhe leggibili: il Caricatore le converte in questi StringName
## e rifiuta i valori sconosciuti, così un errore di battitura emerge al caricamento.
## Lo stesso nome usato in più ruoli (es. "mano": bersaglio, zona, proprietà) è una sola costante.
##
## Nota Godot: &"testo" è uno StringName, una stringa "internata": confrontarne due costa
## quanto confrontare due numeri. Un String e uno StringName uguali risultano == tra loro.

# --- Tipi di effetto (mattoncini) in combattimento -----------------------------------
const DANNO := &"danno"
const BLOCCO := &"blocco"
const CURA := &"cura"
const PESCA := &"pesca"
const ENERGIA := &"energia"
const APPLICA_STATO := &"applica_stato"
const RIMUOVI_STATO := &"rimuovi_stato"
const AGGIUNGI_CARTA := &"aggiungi_carta"
const SCARTA := &"scarta"
const ESILIA := &"esilia"
const ANNULLA_INTENZIONE := &"annulla_intenzione"
const RIPRENDI_DAGLI_SCARTI := &"riprendi_dagli_scarti"
const RUBA_CARTA := &"ruba_carta"
const EVOCA := &"evoca"
const APPLICA_MODIFICATORE := &"applica_modificatore"

const EFFETTI_COMBATTIMENTO: Array[StringName] = [DANNO, BLOCCO, CURA, PESCA, ENERGIA,
	APPLICA_STATO, RIMUOVI_STATO, AGGIUNGI_CARTA, SCARTA, ESILIA, ANNULLA_INTENZIONE,
	RIPRENDI_DAGLI_SCARTI, RUBA_CARTA, EVOCA, APPLICA_MODIFICATORE]
## Effetti "in punti": i modificatori di valore_effetti e le evoluzioni agiscono solo su questi.
const EFFETTI_IN_PUNTI: Array[StringName] = [DANNO, BLOCCO, CURA]

# --- Tipi di effetto fuori dal combattimento (eventi, lasciti) -------------------------
const GRANI := &"grani"
const MEMORIA := &"memoria"
const OTTIENI_CARTA := &"ottieni_carta"
const RIMUOVI_CARTA := &"rimuovi_carta"
const OTTIENI_AMULETO := &"ottieni_amuleto"
const OTTIENI_RIMEDIO := &"ottieni_rimedio"
const BENEDICI := &"benedici"
const VITA := &"vita"
const VITA_MAX := &"vita_max"

const EFFETTI_FUORI_COMBATTIMENTO: Array[StringName] = [GRANI, MEMORIA, OTTIENI_CARTA,
	RIMUOVI_CARTA, OTTIENI_AMULETO, OTTIENI_RIMEDIO, BENEDICI, VITA, VITA_MAX]

# --- Bersagli -------------------------------------------------------------------------
const SE := &"se"
const GIOCATORE := &"giocatore"
const CASA := &"casa"
const SE_O_CASA := &"se_o_casa"
const NEMICO := &"nemico"
const TUTTI_NEMICI := &"tutti_nemici"
const NEMICO_CASUALE := &"nemico_casuale"
const MANO := &"mano"
const CARTA_PIU_COSTOSA_IN_MANO := &"carta_piu_costosa_in_mano"

const BERSAGLI: Array[StringName] = [SE, GIOCATORE, CASA, SE_O_CASA, NEMICO, TUTTI_NEMICI,
	NEMICO_CASUALE, MANO, CARTA_PIU_COSTOSA_IN_MANO]

# --- Zone delle carte e modi di scelta ----------------------------------------------------
const MAZZO := &"mazzo"
const SCARTI := &"scarti"
const ZONE: Array[StringName] = [MAZZO, MANO, SCARTI]
const SCELTA := &"scelta"
const CASUALE := &"casuale"
const MODI: Array[StringName] = [SCELTA, CASUALE]
## Valore speciale di rimuovi_stato: tutte le cariche.
const TUTTE := &"tutte"

# --- Chiavi delle scelte del giocatore (gioca_carta) ------------------------------------
# nemico: uid del nemico (NEMICO); se_o_casa: SE o CASA (SE_O_CASA); liste di uid per:
const RIPRENDI := &"riprendi"
# (le scelte di scarta ed esilia usano le chiavi SCARTA ed ESILIA)

# --- Eventi di gioco --------------------------------------------------------------------
const INIZIO_COMBATTIMENTO := &"inizio_combattimento"
const FINE_COMBATTIMENTO := &"fine_combattimento"
const INIZIO_TURNO := &"inizio_turno"
const FINE_TURNO := &"fine_turno"
const CARTA_GIOCATA := &"carta_giocata"
const SOGLIA_RAGGIUNTA := &"soglia_raggiunta"

const EVENTI: Array[StringName] = [INIZIO_COMBATTIMENTO, FINE_COMBATTIMENTO, INIZIO_TURNO,
	FINE_TURNO, CARTA_GIOCATA, SOGLIA_RAGGIUNTA]

# --- Età -------------------------------------------------------------------------------
const INFANZIA := &"infanzia"
const GIOVINEZZA := &"giovinezza"
const ETA_ADULTA := &"eta_adulta"
const VECCHIAIA := &"vecchiaia"
const ETA: Array[StringName] = [INFANZIA, GIOVINEZZA, ETA_ADULTA, VECCHIAIA]

# --- Momenti del Lascito ----------------------------------------------------------------
const INIZIO_VITA := &"inizio_vita"
const MOMENTI_LASCITO: Array[StringName] = [INIZIO_VITA, INIZIO_COMBATTIMENTO]

# --- Tipi di stato ----------------------------------------------------------------------
const INTENSITA := &"intensita"
const DURATA := &"durata"
const SOGLIA := &"soglia"
const TIPI_STATO: Array[StringName] = [INTENSITA, DURATA, SOGLIA]

# --- Tipi di carta ----------------------------------------------------------------------
const ATTACCO := &"attacco"
const DIFESA := &"difesa"
const ABILITA := &"abilita"
const NEGATIVA := &"negativa"
const TIPI_CARTA: Array[StringName] = [ATTACCO, DIFESA, ABILITA, NEGATIVA]

# --- Nemici: comportamenti, livelli, forme della fattura ---------------------------------
const PESATO := &"pesato"
const SEQUENZA := &"sequenza"
const COMPORTAMENTI: Array[StringName] = [PESATO, SEQUENZA]

const NORMALE := &"normale"
const ELITE := &"elite"
const TIRANNO := &"tiranno"
const LIVELLI: Array[StringName] = [NORMALE, ELITE, TIRANNO]

const BASE := &"base"
const TOCCATA := &"toccata"
const DIVORATA := &"divorata"
## In ordine di gravità: ogni forma include le aggiunte delle precedenti.
const FORME: Array[StringName] = [BASE, TOCCATA, DIVORATA]

# --- Modificatori -----------------------------------------------------------------------
const SOMMA := &"somma"
const MOLTIPLICA := &"moltiplica"
const IMPOSTA := &"imposta"
const OPERAZIONI: Array[StringName] = [SOMMA, MOLTIPLICA, IMPOSTA]

const TURNO := &"turno"
const COMBATTIMENTO := &"combattimento"
const STIRPE := &"stirpe"
## In ordine di lunghezza: la fine di un combattimento è anche la fine del turno.
const DURATE: Array[StringName] = [TURNO, COMBATTIMENTO, VITA, STIRPE]

const COSTO := &"costo"
const VALORE_EFFETTI := &"valore_effetti"
const DANNO_SUBITO := &"danno_subito"
const PREZZO := &"prezzo"
const RICOMPENSA_GRANI := &"ricompensa_grani"
const PROPRIETA: Array[StringName] = [COSTO, VALORE_EFFETTI, VITA_MAX, MANO, ENERGIA,
	DANNO_SUBITO, PREZZO, RICOMPENSA_GRANI]

## Tipi di oggetto a cui si applica un modificatore (SE = chi porta lo stato).
const CARTA := &"carta"
const TIPI_OGGETTO: Array[StringName] = [GIOCATORE, CASA, CARTA, NEMICO, SE]

const EREDITATA := &"ereditata"
const UID := &"uid"
const ID := &"id"
const TAG := &"tag"
const RARITA := &"rarita"
const TIPO := &"tipo"
const FAMIGLIA := &"famiglia"
const CASATA := &"casata"
const RUOLO := &"ruolo"
const LIVELLO := &"livello"
const FILTRI: Array[StringName] = [EREDITATA, UID, ID, TAG, RARITA, TIPO, FAMIGLIA, CASATA, RUOLO, LIVELLO]

# --- Voci del registro (oltre agli eventi e ai tipi di effetto, che si riusano) ----------
const R_INTENZIONE := &"intenzione"
const R_INTENZIONE_ESEGUITA := &"intenzione_eseguita"
const R_INTENZIONE_SALTATA := &"intenzione_saltata"
const R_INTENZIONE_ANNULLATA := &"intenzione_annullata"
const R_ANNULLAMENTO_FALLITO := &"annullamento_fallito"
const R_RIMESCOLA := &"rimescola"
const R_MORTE := &"morte"
const R_CASA_A_ZERO := &"casa_a_zero"
const R_STATO_APPLICATO := &"stato_applicato"
const R_STATO_RIMOSSO := &"stato_rimosso"
const R_AGGANCIO_STATO := &"aggancio_stato"
const R_EVOCATO := &"evocato"
const R_EVOCAZIONE_FALLITA := &"evocazione_fallita"
const R_CARTA_AGGIUNTA := &"carta_aggiunta"
const R_SCARTATA := &"scartata"
const R_ESILIATA := &"esiliata"
const R_RIPRESA := &"ripresa"
const R_RUBATA := &"rubata"
const R_MODIFICATORE := &"modificatore"
const R_INTENZIONE_POTENZIATA := &"intenzione_potenziata"
