# Report della simulazione di bilanciamento

Generato da `strumenti/simula.gd` il 2026-11-06. **Nessun numero è stato corretto: il report misura e basta.**

## Come
- Mazzo base della casata **masciare** (10 carte), 1000 combattimenti per nemico e per età (semi da 1 a 1000), forma base dei nemici.
- Età: vita e carte in mano dal foglio (scheda Età); casa (35) in tutte le età; vita piena a inizio combattimento.
- Strategia (`core/simulazione/giocatore_automatico.gd`): se un'intenzione visibile farà danni a te o alla casa oltre il blocco, gioca la carta che blocca di più (prima te, poi la casa); altrimenti la carta che fa più danni, sul nemico con meno vita; poi il resto.
- Obiettivo di confronto: **4.0 turni** per un combattimento normale (ancora del foglio: 3, per un mazzo medio tra le casate) e **10-15%** di vita persa (scheda Ancore).
- Tempo di calcolo: 63.2 s.

## Giovinezza

| Nemico | Vittorie | Turni medi | Turni (min–max) | Vita persa media | Vita persa (10°–90° perc.) | Rispetto all'obiettivo | Casa persa media | Tratti negativi | Fattura a fine combattimento |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| lupenaro | 100.0% | 6.88 | 4–11 | 17.3% | 11.0%–23.0% | turni sopra, vita sopra | 0.0 | 0.0% | 0.00 |
| janara | 100.0% | 5.39 | 3–9 | 0.0% | 0.0%–0.0% | turni sopra, vita sotto | 2.0 | 0.0% | 0.00 |
| pantafica | 100.0% | 5.83 | 4–10 | 2.0% | 0.0%–6.0% | turni sopra, vita sotto | 0.0 | 0.0% | 2.76 |
| munaciello_offeso | 100.0% | 4.61 | 4–8 | 0.5% | 0.0%–3.0% | turni sopra, vita sotto | 0.0 | 0.0% | 0.00 |

## Età adulta

| Nemico | Vittorie | Turni medi | Turni (min–max) | Vita persa media | Vita persa (10°–90° perc.) | Rispetto all'obiettivo | Casa persa media | Tratti negativi | Fattura a fine combattimento |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| lupenaro | 100.0% | 7.96 | 5–14 | 15.2% | 8.2%–23.5% | turni sopra, vita sopra | 0.0 | 0.0% | 0.00 |
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

## Forma divorata

Tutti i nemici in forma divorata (vita × 1,6, danni × 1,3, intenzione potenziata × 1,5 in più), stesso mazzo base. "Colpo potenziato": danno subito dal giocatore quando il nemico esegue la sua intenzione potenziata (dopo il blocco). La Janara potenzia l'assalto alla casa, che non colpisce il giocatore.

| Età (vita) | Strategia | Nemico | Vittorie | Turni medi | Vita persa media | Colpi potenziati subiti | Danno medio del colpo potenziato | Colpo potenziato più forte | Sconfitte per il colpo potenziato |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| giovinezza (100) | difende | lupenaro | 7.1% | 9.07 | 99.6% | 2062 | 34.9 | 48 | 48.5% |
| giovinezza (100) | difende | janara | 100.0% | 9.44 | 0.0% | 4868 | 0.0 | 0 | 0.0% |
| giovinezza (100) | difende | pantafica | 98.7% | 10.41 | 51.4% | 4837 | 9.9 | 25 | 0.9% |
| giovinezza (100) | difende | munaciello_offeso | 100.0% | 7.91 | 23.6% | 4161 | 5.7 | 20 | 0.0% |
| giovinezza (100) | solo attacco | lupenaro | 99.8% | 6.43 | 81.1% | 1002 | 42.6 | 51 | 0.2% |
| giovinezza (100) | solo attacco | janara | 100.0% | 6.88 | 0.0% | 3400 | 0.0 | 0 | 0.0% |
| giovinezza (100) | solo attacco | pantafica | 100.0% | 5.94 | 45.0% | 2422 | 16.8 | 25 | 0.0% |
| giovinezza (100) | solo attacco | munaciello_offeso | 100.0% | 6.58 | 27.2% | 3355 | 8.1 | 20 | 0.0% |
| eta adulta (85) | difende | lupenaro | 1.2% | 8.96 | 99.8% | 2078 | 33.2 | 42 | 56.6% |
| eta adulta (85) | difende | janara | 100.0% | 9.65 | 0.0% | 5041 | 0.0 | 0 | 0.0% |
| eta adulta (85) | difende | pantafica | 93.6% | 11.01 | 54.2% | 5264 | 7.8 | 21 | 4.1% |
| eta adulta (85) | difende | munaciello_offeso | 100.0% | 8.26 | 19.6% | 4416 | 3.8 | 20 | 0.0% |
| eta adulta (85) | solo attacco | lupenaro | 90.8% | 5.18 | 89.2% | 1000 | 46.1 | 51 | 0.0% |
| eta adulta (85) | solo attacco | janara | 100.0% | 5.43 | 0.0% | 2546 | 0.0 | 0 | 0.0% |
| eta adulta (85) | solo attacco | pantafica | 100.0% | 5.11 | 50.9% | 2003 | 19.1 | 25 | 0.0% |
| eta adulta (85) | solo attacco | munaciello_offeso | 100.0% | 5.29 | 32.5% | 2584 | 10.7 | 20 | 0.0% |
| vecchiaia (60) | difende | lupenaro | 0.0% | 8.00 | 100.0% | 1999 | 26.6 | 44 | 99.9% |
| vecchiaia (60) | difende | janara | 100.0% | 9.30 | 0.0% | 4957 | 0.0 | 0 | 0.0% |
| vecchiaia (60) | difende | pantafica | 87.2% | 11.19 | 61.3% | 5426 | 6.1 | 17 | 7.8% |
| vecchiaia (60) | difende | munaciello_offeso | 100.0% | 8.67 | 17.8% | 4730 | 2.3 | 16 | 0.0% |
| vecchiaia (60) | solo attacco | lupenaro | 42.4% | 3.98 | 81.8% | 576 | 30.1 | 40 | 57.6% |
| vecchiaia (60) | solo attacco | janara | 100.0% | 4.58 | 0.0% | 2051 | 0.0 | 0 | 0.0% |
| vecchiaia (60) | solo attacco | pantafica | 97.0% | 4.24 | 65.6% | 1625 | 20.8 | 25 | 3.0% |
| vecchiaia (60) | solo attacco | munaciello_offeso | 100.0% | 4.46 | 46.4% | 2053 | 13.5 | 20 | 0.0% |

## Confronto con la Tappa 2b

**Tappa 2b**: report precedente (Ululato 10 blocco). **Tappa 2c**: dati attuali (Ululato 6 blocco, D63; la forma divorata non entra in queste tabelle, che usano la forma base). Stessa strategia, stessi semi, 1000 combattimenti per riga.

### Giovinezza

| Nemico | Turni 2b | Turni 2c | Vita persa 2b | Vita persa 2c | Casa persa 2b | Casa persa 2c |
| --- | --- | --- | --- | --- | --- | --- |
| lupenaro | 7.48 | **6.88** | 19.5% | **17.3%** | 0.0 | **0.0** |
| janara | 5.39 | **5.39** | 0.0% | **0.0%** | 2.0 | **2.0** |
| pantafica | 5.83 | **5.83** | 2.0% | **2.0%** | 0.0 | **0.0** |
| munaciello_offeso | 4.61 | **4.61** | 0.5% | **0.5%** | 0.0 | **0.0** |

### Età adulta

| Nemico | Turni 2b | Turni 2c | Vita persa 2b | Vita persa 2c | Casa persa 2b | Casa persa 2c |
| --- | --- | --- | --- | --- | --- | --- |
| lupenaro | 8.42 | **7.96** | 16.4% | **15.2%** | 0.0 | **0.0** |
| janara | 5.01 | **5.01** | 0.0% | **0.0%** | 1.0 | **1.0** |
| pantafica | 5.41 | **5.41** | 0.8% | **0.8%** | 0.0 | **0.0** |
| munaciello_offeso | 4.16 | **4.16** | 0.1% | **0.1%** | 0.0 | **0.0** |

### Riferimento: età adulta, solo attacco

| Nemico | Turni 2b | Turni 2c | Vita persa 2b | Vita persa 2c | Casa persa 2b | Casa persa 2c |
| --- | --- | --- | --- | --- | --- | --- |
| lupenaro | 3.31 | **3.31** | 20.9% | **20.9%** | 0.0 | **0.0** |
| janara | 3.50 | **3.50** | 0.0% | **0.0%** | 15.1 | **15.1** |
| pantafica | 3.30 | **3.30** | 10.4% | **10.4%** | 0.0 | **0.0** |
| munaciello_offeso | 3.43 | **3.43** | 4.8% | **4.8%** | 0.0 | **0.0** |

## Osservazioni
*Scritte a mano dopo l'esecuzione del 2026-11-06 (Tappa 2c). La sezione "Confronto con la Tappa 2b" è composta dal report precedente: se il report viene rigenerato, queste due sezioni vanno rifatte.*

### Forma base (confronto con la Tappa 2b)
1. **Cambia solo il Lupenaro**, come previsto (D63 tocca solo l'Ululato): con la strategia prudente scende da 7,5-8,4 a 6,9-8,0 turni e da 16-20% a 15-17% di vita persa. Resta il nemico più duro e sopra la fascia del 10-15%, ma di poco. Con la strategia "solo attacco" non cambia nulla (il combattimento finisce prima che l'Ululato conti).
2. Gli altri nemici sono identici alla Tappa 2b (stessi semi, nessun dato cambiato).

### Forma divorata: il Morso della luna da 55 è letale?
3. **Da solo, a vita piena, no** in nessuna età: 55 è meno della vita minima (60 in vecchiaia). Il colpo più forte subito in simulazione è 40-51, perché il blocco ne assorbe sempre una parte.
4. **Ma è il colpo che chiude i combattimenti**: arriva al quarto turno della sequenza, dopo due Morsi da 20. Con il mazzo base:
   - in **vecchiaia** il giocatore perde quasi sempre, e il colpo finale è il Morso della luna nel **99,9%** dei combattimenti con la strategia prudente e nel **58%** con quella aggressiva;
   - in **età adulta** perde quasi sempre con la strategia prudente (vince l'1%; il Morso della luna dà il colpo finale nel 57%), mentre attaccando soltanto vince il 91% ma con l'89% di vita persa;
   - in **giovinezza** la strategia prudente vince il 7% (colpo finale del Morso della luna nel 49%), quella aggressiva quasi sempre ma con l'81% di vita persa.
5. **Il Lupenaro divorato è di un'altra categoria rispetto agli altri divorati**: la Pantafica divorata costa 45-66% di vita (perde a volte in vecchiaia), il Munaciello 18-46%, la Janara 0% al giocatore (il suo colpo potenziato va alla casa). Il Lupenaro divorato costa 80-100% e, con la strategia prudente, si perde quasi sempre.
6. **Limite importante della misura**: la forma divorata arriva dalla generazione 5, quando il mazzo ha molte carte di famiglia invecchiate; qui è usato il mazzo base della prima generazione. I numeri dicono quanto è pericoloso il colpo, non quanto lo sarà davvero nel gioco.

Domande che emergono (nessun numero è stato toccato):
- Il Morso della luna divorato non uccide a vita piena, ma in vecchiaia chiude quasi ogni combattimento contro il Lupenaro divorato con il mazzo base. Va verificato con un mazzo realistico di generazione 5 (quando esisterà la stirpe), oppure si vuole già ora un limite (es. il colpo potenziato non supera una quota della vita massima)?
