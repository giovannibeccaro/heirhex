# Risposte di Giovanni (Tappa 2c, 2026-11-06)

Decisione registrata nella cartella di design: `05-decisioni/registro-decisioni.md`, **D65**. Il foglio `06-prototipo/bilanciamento.xlsx` è già aggiornato.

**Domanda sul Morso della luna divorato: nessun limite.** Il problema era la misura: il mazzo base contro la forma divorata (generazione 5) non dice niente. Non va giudicato solo il Lupenaro: probabilmente sono gli altri divorati a essere troppo deboli.

## Tappa 2d — taratura contro i mazzi di riferimento

Novità nel foglio:
- **Scheda "Mazzi di riferimento"**: un mazzo medio per fase (`inizio` gen. 1, `meta` gen. 3, `fine` gen. 5), colonne Fase, Generazione, Carta (id), Copie, Livello (`0`, `di famiglia` = un'evoluzione Più forte, `degli avi` = due; valori dalla scheda Invecchiamento). Solo Masciare.
- **Scheda "Forme fattura"**, colonne F-J: turni obiettivo (min, max), vita persa obiettivo (min, max), mazzo di riferimento della forma. Base 4 turni / 8-12%; toccata 4-5 / 10-15%; divorata 4-5 / 12-18%.
- **Ancore** righe 8-9: vita persa obiettivo ora 8-12%.

Compiti (un commit ciascuno, ramo nuovo da `main`):
1. **T2.10** Esportare le due novità (schema e caricatore aggiornati, validatore: le carte dei mazzi esistono, i livelli sono validi, ogni forma ha un mazzo). Test.
2. **T2.11** Applicare l'invecchiamento alle carte dei mazzi di riferimento in simulazione (Più forte = regola della scheda Invecchiamento, una o due volte). Test.
3. **T2.12** Simulazione: ogni forma contro il mazzo della sua fase, tutte le età, almeno una strategia "ragionevole" oltre alle due estreme (es. si difende solo quando l'intenzione annunciata supera una soglia). Report con turni, vita persa e distanza dagli obiettivi.
4. **T2.13** **Proporre** nuovi numeri (vita e intenzioni dei nemici, moltiplicatori delle forme in Forme fattura) per entrare negli obiettivi, con la simulazione che lo dimostra. **Non modificare il foglio né i dati**: scrivi la proposta nel diario, la decidiamo con Giovanni.

Se i mazzi di riferimento ti sembrano irrealistici (troppo forti o troppo deboli rispetto a quello che le regole permettono), dillo nel diario invece di correggerli.

## Velocità delle simulazioni (richiesta di Giovanni)
- Nel lavoro di tutti i giorni usa **200 combattimenti per riga** (rende il default di `simula.gd` 200). Bastano per le medie di turni e vita persa: l'errore è intorno a ±1 punto percentuale.
- **1000** solo per confermare una proposta finale (T2.13), e solo sulle righe che la riguardano.
- Fai girare solo gli scenari che servono al compito corrente (aggiungi un'opzione per scegliere scenario, forma ed età). Il report resta completo quando si conferma.
- Scrivi nel diario quanto tempo ha richiesto ogni esecuzione.
