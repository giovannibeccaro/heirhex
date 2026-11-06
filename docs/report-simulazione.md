# Report della simulazione di bilanciamento

Generato da `strumenti/simula.gd` il 2026-11-06. **Nessun numero è stato corretto: il report misura e basta.**

## Come
- Mazzo base della casata **masciare** (10 carte), 1000 combattimenti per nemico e per età (semi da 1 a 1000), forma base dei nemici.
- Età: vita e carte in mano dal foglio (scheda Età); casa (35) in tutte le età; vita piena a inizio combattimento.
- Strategia (`core/simulazione/giocatore_automatico.gd`): se un'intenzione visibile farà danni a te o alla casa oltre il blocco, gioca la carta che blocca di più (prima te, poi la casa); altrimenti la carta che fa più danni, sul nemico con meno vita; poi il resto.
- Obiettivo di confronto: **4.0 turni** per un combattimento normale (ancora del foglio: 3, per un mazzo medio tra le casate) e **10-15%** di vita persa (scheda Ancore).
- Tempo di calcolo: 14.4 s.

## Giovinezza

| Nemico | Vittorie | Turni medi | Turni (min–max) | Vita persa media | Vita persa (10°–90° perc.) | Rispetto all'obiettivo | Casa persa media | Tratti negativi | Fattura a fine combattimento |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| lupenaro | 100.0% | 7.48 | 5–11 | 19.5% | 11.0%–28.0% | turni sopra, vita sopra | 0.0 | 0.0% | 0.00 |
| janara | 100.0% | 5.39 | 3–9 | 0.0% | 0.0%–0.0% | turni sopra, vita sotto | 2.0 | 0.0% | 0.00 |
| pantafica | 100.0% | 5.83 | 4–10 | 2.0% | 0.0%–6.0% | turni sopra, vita sotto | 0.0 | 0.0% | 2.76 |
| munaciello_offeso | 100.0% | 4.61 | 4–8 | 0.5% | 0.0%–3.0% | turni sopra, vita sotto | 0.0 | 0.0% | 0.00 |

## Età adulta

| Nemico | Vittorie | Turni medi | Turni (min–max) | Vita persa media | Vita persa (10°–90° perc.) | Rispetto all'obiettivo | Casa persa media | Tratti negativi | Fattura a fine combattimento |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| lupenaro | 100.0% | 8.42 | 5–15 | 16.4% | 8.2%–25.9% | turni sopra, vita sopra | 0.0 | 0.0% | 0.00 |
| janara | 100.0% | 5.01 | 3–9 | 0.0% | 0.0%–0.0% | turni sopra, vita sotto | 1.0 | 0.0% | 0.00 |
| pantafica | 100.0% | 5.41 | 3–9 | 0.8% | 0.0%–2.4% | turni sopra, vita sotto | 0.0 | 0.0% | 2.49 |
| munaciello_offeso | 100.0% | 4.16 | 3–6 | 0.1% | 0.0%–0.0% | turni nella norma, vita sotto | 0.0 | 0.0% | 0.00 |

## Riferimento: età adulta, strategia che attacca soltanto

| Nemico | Vittorie | Turni medi | Turni (min–max) | Vita persa media | Vita persa (10°–90° perc.) | Rispetto all'obiettivo | Casa persa media | Tratti negativi | Fattura a fine combattimento |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| lupenaro | 100.0% | 3.31 | 3–4 | 20.9% | 18.8%–22.4% | turni sotto, vita sopra | 0.0 | 0.0% | 0.00 |
| janara | 100.0% | 3.50 | 3–5 | 0.0% | 0.0%–0.0% | turni nella norma, vita sotto | 15.1 | 0.0% | 0.00 |
| pantafica | 100.0% | 3.30 | 3–5 | 10.4% | 1.2%–17.6% | turni sotto, vita nella norma | 0.0 | 0.0% | 1.41 |
| munaciello_offeso | 100.0% | 3.43 | 3–5 | 4.8% | 0.0%–11.8% | turni sotto, vita sotto | 0.0 | 0.0% | 0.00 |

Legenda: "turni nella norma" = media entro ±0,5 dall'obiettivo; "vita nella norma" = media nella fascia delle ancore. Casa persa: punti di vita della casa (35) persi in media.

## Prima / dopo (Tappa 2b)

**Prima**: report del 2026-11-06 sui dati vecchi (efficienza 0,8, nemici 72 di vita, danni base, culla solo dall'età adulta). **Dopo**: dati attuali (efficienza 0,6, nemici 54 di vita, danni dei nemici +25%, casa in tutte le età). Stessa strategia, stessi semi, 1000 combattimenti per riga. In giovinezza la culla prima non c'era: la casa persa "prima" è 0 per costruzione.

### Giovinezza

| Nemico | Turni medi prima | Turni medi dopo | Vita persa prima | Vita persa dopo | Casa persa prima | Casa persa dopo |
| --- | --- | --- | --- | --- | --- | --- |
| lupenaro | 8.29 | **7.48** | 9.1% | **19.5%** | 0.0 | **0.0** |
| janara | 5.56 | **5.39** | 0.0% | **0.0%** | 0.0 | **2.0** |
| pantafica | 6.74 | **5.83** | 0.6% | **2.0%** | 0.0 | **0.0** |
| munaciello_offeso | 6.13 | **4.61** | 0.2% | **0.5%** | 0.0 | **0.0** |

### Età adulta

| Nemico | Turni medi prima | Turni medi dopo | Vita persa prima | Vita persa dopo | Casa persa prima | Casa persa dopo |
| --- | --- | --- | --- | --- | --- | --- |
| lupenaro | 7.95 | **8.42** | 4.8% | **16.4%** | 0.0 | **0.0** |
| janara | 5.94 | **5.01** | 0.0% | **0.0%** | 0.3 | **1.0** |
| pantafica | 6.13 | **5.41** | 0.2% | **0.8%** | 0.0 | **0.0** |
| munaciello_offeso | 5.18 | **4.16** | 0.1% | **0.1%** | 0.0 | **0.0** |

### Riferimento: età adulta, solo attacco

| Nemico | Turni medi prima | Turni medi dopo | Vita persa prima | Vita persa dopo | Casa persa prima | Casa persa dopo |
| --- | --- | --- | --- | --- | --- | --- |
| lupenaro | 5.04 | **3.31** | 29.6% | **20.9%** | 0.0 | **0.0** |
| janara | 4.38 | **3.50** | 0.0% | **0.0%** | 12.0 | **15.1** |
| pantafica | 4.26 | **3.30** | 10.1% | **10.4%** | 0.0 | **0.0** |
| munaciello_offeso | 4.58 | **3.43** | 3.6% | **4.8%** | 0.0 | **0.0** |

## Osservazioni
*Scritte a mano dopo l'esecuzione del 2026-11-06 (Tappa 2b). La sezione "Prima / dopo" è stata composta dal report precedente: se il report viene rigenerato, queste due sezioni vanno rifatte.*

1. **I combattimenti si sono accorciati, ma con la strategia "difende sempre" restano sopra i 4 turni** dell'obiettivo D58: da 5-8 a 4,2-5,8 turni contro Janara, Pantafica e Munaciello. Il Munaciello in età adulta (4,16) è praticamente sull'obiettivo.
2. **Il Lupenaro si è accorciato poco o per niente** (giovinezza da 8,3 a 7,5 turni; età adulta da 8,0 a 8,4). I suoi colpi ora valgono 15 e 28: la strategia, che blocca tutto il danno annunciato prima di attaccare, spende quasi tutta la mano in difesa nei turni del Morso della luna. In più l'Ululato (10 blocco) assorbe gli attacchi. È l'unico nemico che oggi fa davvero male: 16-20% di vita persa, sopra la fascia del 10-15%.
3. **Con la strategia "solo attacco" tutti stanno tra 3,3 e 3,5 turni**, cioè sotto l'obiettivo di 4. Un giocatore vero, che si difende solo quando conviene, starà tra le due strategie: **l'obiettivo dei 4 turni è dentro la forbice per tutti i nemici**. Prima della revisione non lo era: anche attaccando soltanto si restava a 4-5 turni.
4. **Vita persa**: Lupenaro sopra la fascia (16-21%), Pantafica nella fascia solo se non ci si difende (10%, altrimenti 1-2%), Munaciello sotto (0-5%). La Janara non toglie mai vita al giocatore: colpisce solo la casa.
5. **La casa**: contro la Janara la strategia difensiva la protegge quasi del tutto (1-2 punti persi su 35); attaccando soltanto se ne perdono 15 (43% della casa) a combattimento. In nessun caso la casa arriva a 0 (nessun tratto negativo). Con la casa in tutte le età la Janara ora ha senso anche in giovinezza.
6. **Fattura**: contro la Pantafica restano circa 2,5-2,8 cariche a fine combattimento (prima circa 3). Due incontri nella stessa vita portano a 5-6 cariche, vicino alla soglia di 7.
7. **Cosa non misura questa simulazione**: il costo di Fattura, Paura, Malocchio e Dispetto oltre il singolo combattimento; la forma toccata e divorata; mazzi con carte di famiglia. Pantafica e Munaciello "costano" anche in questi modi, non solo in vita persa.

Domande che emergono (nessun numero è stato toccato):
- Il Lupenaro, con il Morso della luna a 28, è il nemico più duro con un buon margine: è voluto (è quello che insegna a leggere le intenzioni) o va avvicinato agli altri?
- Pantafica e Munaciello tolgono poca vita diretta: il loro peso sta negli stati e nelle carte sporche, che questa misura non vede. Serve una metrica diversa per loro (es. Fattura accumulata in una vita)?
