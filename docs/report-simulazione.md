# Report della simulazione di bilanciamento

Generato da `strumenti/simula.gd` il 2026-11-06. **Nessun numero è stato corretto: il report misura e basta.**

## Come
- Mazzo base della casata **masciare** (10 carte), 1000 combattimenti per nemico e per età (semi da 1 a 1000), forma base dei nemici.
- Età: vita e carte in mano dal foglio (scheda Età); culla (35) attiva dall'età adulta; vita piena a inizio combattimento.
- Strategia (`core/simulazione/giocatore_automatico.gd`): se un'intenzione visibile farà danni a te o alla culla oltre il blocco, gioca la carta che blocca di più (prima te, poi la culla); altrimenti la carta che fa più danni, sul nemico con meno vita; poi il resto.
- Ancore di confronto (scheda Ancore): **3 turni** per un combattimento normale, **10-15%** di vita persa.
- Tempo di calcolo: 16.2 s.

## Giovinezza (vita 100, mano 4, senza culla)

| Nemico | Vittorie | Turni medi | Turni (min–max) | Vita persa media | Vita persa (10°–90° perc.) | Rispetto alle ancore | Culla persa media | Tratti negativi | Fattura a fine combattimento |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| lupenaro | 100.0% | 8.29 | 6–13 | 9.1% | 3.0%–16.0% | turni sopra, vita sotto | 0.0 | 0.0% | 0.00 |
| janara | 100.0% | 5.56 | 4–9 | 0.0% | 0.0%–0.0% | turni sopra, vita sotto | 0.0 | 0.0% | 0.00 |
| pantafica | 100.0% | 6.74 | 5–10 | 0.6% | 0.0%–3.0% | turni sopra, vita sotto | 0.0 | 0.0% | 3.17 |
| munaciello_offeso | 100.0% | 6.13 | 4–9 | 0.2% | 0.0%–1.0% | turni sopra, vita sotto | 0.0 | 0.0% | 0.00 |

## Età adulta (vita 85, mano 5, culla)

| Nemico | Vittorie | Turni medi | Turni (min–max) | Vita persa media | Vita persa (10°–90° perc.) | Rispetto alle ancore | Culla persa media | Tratti negativi | Fattura a fine combattimento |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| lupenaro | 100.0% | 7.95 | 7–13 | 4.8% | 0.0%–9.4% | turni sopra, vita sotto | 0.0 | 0.0% | 0.00 |
| janara | 100.0% | 5.94 | 4–10 | 0.0% | 0.0%–0.0% | turni sopra, vita sotto | 0.3 | 0.0% | 0.00 |
| pantafica | 100.0% | 6.13 | 4–9 | 0.2% | 0.0%–0.0% | turni sopra, vita sotto | 0.0 | 0.0% | 2.87 |
| munaciello_offeso | 100.0% | 5.18 | 4–7 | 0.1% | 0.0%–0.0% | turni sopra, vita sotto | 0.0 | 0.0% | 0.00 |

## Riferimento: età adulta, strategia che attacca soltanto

| Nemico | Vittorie | Turni medi | Turni (min–max) | Vita persa media | Vita persa (10°–90° perc.) | Rispetto alle ancore | Culla persa media | Tratti negativi | Fattura a fine combattimento |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| lupenaro | 100.0% | 5.04 | 5–6 | 29.6% | 24.7%–34.1% | turni sopra, vita sopra | 0.0 | 0.0% | 0.00 |
| janara | 100.0% | 4.38 | 4–6 | 0.0% | 0.0%–0.0% | turni sopra, vita sotto | 12.0 | 0.0% | 0.00 |
| pantafica | 100.0% | 4.26 | 4–6 | 10.1% | 3.5%–16.5% | turni sopra, vita nella norma | 0.0 | 0.0% | 1.82 |
| munaciello_offeso | 100.0% | 4.58 | 4–7 | 3.6% | 0.0%–9.4% | turni sopra, vita sotto | 0.0 | 0.0% | 0.00 |

Legenda: "turni nella norma" = media entro ±0,5 dall'ancora; "vita nella norma" = media nella fascia delle ancore.

## Osservazioni
*Scritte a mano dopo l'esecuzione del 2026-11-06; se il report viene rigenerato, questa sezione va riscritta.*

1. **I combattimenti durano circa il doppio dell'ancora** (5-8 turni contro 3), con qualsiasi nemico ed età. Anche la strategia che attacca soltanto resta sopra (4-5 turni). Il motivo è aritmetico: nel mazzo base delle Masciare le sole carte di danno sono 4 Scongiuro (10 danni), cioè 40 danni ogni 10 carte. Con 4-5 carte in mano il massimo è circa 16-20 danni a turno, contro i 24 che l'ancora presume (30 di valore × 0,8 di efficienza). Per finire in 3 turni contro 72 di vita servirebbero 24 danni a turno: il mazzo base fa soprattutto difesa (6 carte su 10).
2. **La vita persa è molto sotto l'ancora** (0-9% contro 10-15%), tranne il Lupenaro in giovinezza (9%, appena sotto). La strategia blocca ogni attacco annunciato e il blocco dimezzato si accumula da un turno all'altro: con 6 carte di difesa su 10, gli attacchi da 10-12 vengono quasi sempre assorbiti. Il Lupenaro è l'unico che fa male, grazie al Morso della luna (22).
3. **Contro la Janara il giocatore non perde mai vita**: tutti i suoi danni vanno alla culla. In giovinezza (culla non attiva) non fa nulla. Se compare anche in giovinezza (`eta_comparsa`), oggi è un combattimento senza rischio. In età adulta la strategia protegge la culla quasi del tutto (0,3 di culla persa in media).
4. **Fattura**: contro la Pantafica restano in media circa 3 cariche di Fattura a fine combattimento (persistono per la vita). Due Pantafiche nella stessa vita portano quasi alla soglia di 7, come voleva il design.
5. **Riferimento "solo attacco"**: dimezza la differenza sui turni ma alza molto la vita persa contro il Lupenaro (30%); contro la Pantafica la vita persa cade nella fascia dell'ancora (10%). La difesa è un vero compromesso, non una scelta dominante: buon segno per la culla e per il blocco dimezzato.
6. **Limiti della misura**: la strategia è ingenua (non pianifica, non tiene il blocco per il colpo grosso, gioca le carte di pesca per ultime); il mazzo è solo quello base (alla prima generazione, D48: "le Masciare partono deboli, ed è voluto"); vita piena a ogni combattimento. Un giocatore vero e un mazzo con carte di famiglia accorcerebbero i combattimenti.

Domanda di bilanciamento che emerge (da decidere con Giovanni, nessun numero è stato toccato): l'ancora dei 3 turni vale per il mazzo base o per un mazzo "medio" di metà vita? Se vale per il mazzo base, la vita dei nemici normali (72) è circa il doppio del dovuto, oppure il mazzo base ha troppa poca offesa.
