# Report della simulazione di bilanciamento

Generato da `strumenti/simula.gd` il 2026-11-07. **Nessun numero è stato corretto: il report misura e basta.**

## Come
- **Con la proposta di `res://docs/proposta-taratura.json`**, applicata solo in memoria: foglio e dati non sono cambiati.
- D65: ogni forma della fattura si misura contro il **mazzo di riferimento della sua fase** (scheda Mazzi di riferimento) e i suoi **obiettivi** (scheda Forme fattura, colonne F-J). Carte con livello: evoluzione "Più forte" una o due volte; contano come ereditate (per le Radici).
- 1000 combattimenti per riga (semi da 1 a 1000), un nemico normale alla volta, vita piena a inizio combattimento, casa 35 in tutte le età.
- Strategie (`core/simulazione/giocatore_automatico.gd`): **ragionevole** = prima le carte che preparano (pesca, Radici); si difende solo da un colpo che supera il 15% della vita massima o che sarebbe letale, e solo finché resta sopra quella soglia; se può uccidere il nemico in questo turno attacca. **Prudente** = blocca ogni danno annunciato prima di attaccare. **Aggressiva** = non si difende mai prima di attaccare.
- Gli obiettivi si confrontano con la strategia **ragionevole** (D65: "con un gioco ragionevole"). Δ = distanza dall'intervallo obiettivo (0 = dentro; turni in turni, vita in punti percentuali). Un obiettivo di turni esatto ("4") vale ±0,5.
- Tempo di calcolo: 164 s.

## Riepilogo (strategia ragionevole, media sulle tre età)

| Forma | Mazzo | Obiettivo turni | Obiettivo vita persa | Nemico | Turni | Vita persa | Δ turni | Δ vita | Dentro? |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| base | inizio | 3.5-4.5 | 8-12% | lupenaro | 4.02 | 11.2% | 0 | 0 | sì |
| base | inizio | 3.5-4.5 | 8-12% | janara | 4.10 | 0.0% | 0 | -8.0 | no |
| base | inizio | 3.5-4.5 | 8-12% | pantafica | 4.03 | 10.8% | 0 | 0 | sì |
| base | inizio | 3.5-4.5 | 8-12% | munaciello_offeso | 4.21 | 10.2% | 0 | 0 | sì |
| toccata | meta | 4-5 | 10-15% | lupenaro | 3.83 | 15.3% | -0.2 | +0.3 | no |
| toccata | meta | 4-5 | 10-15% | janara | 3.88 | 0.0% | -0.1 | -10.0 | no |
| toccata | meta | 4-5 | 10-15% | pantafica | 4.14 | 16.7% | 0 | +1.7 | no |
| toccata | meta | 4-5 | 10-15% | munaciello_offeso | 3.74 | 11.7% | -0.3 | 0 | no |
| divorata | fine | 4-5 | 12-18% | lupenaro | 3.70 | 13.9% | -0.3 | 0 | no |
| divorata | fine | 4-5 | 12-18% | janara | 3.76 | 0.0% | -0.2 | -12.0 | no |
| divorata | fine | 4-5 | 12-18% | pantafica | 4.30 | 18.2% | 0 | +0.2 | no |
| divorata | fine | 4-5 | 12-18% | munaciello_offeso | 3.93 | 16.3% | -0.1 | 0 | no |

## Forma base — mazzo "inizio" (generazione 1, 10 carte)

Obiettivi: 3.5-4.5 turni, 8-12% di vita persa.

| Età (vita) | Strategia | Nemico | Vittorie | Turni medi | Vita persa media | Vita persa 90° perc. | Casa persa | Fattura a fine | Δ turni | Δ vita |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| giovinezza (100) | ragionevole | lupenaro | 100.0% | 4.60 | 9.7% | 14.0% | 0.0 | 0.00 | +0.1 | 0 |
| giovinezza (100) | ragionevole | janara | 100.0% | 4.67 | 0.0% | 0.0% | 2.3 | 0.00 | +0.2 | -8.0 |
| giovinezza (100) | ragionevole | pantafica | 100.0% | 4.66 | 8.1% | 13.0% | 0.0 | 2.08 | +0.2 | 0 |
| giovinezza (100) | ragionevole | munaciello_offeso | 100.0% | 4.94 | 7.2% | 14.0% | 0.0 | 0.00 | +0.4 | -0.8 |
| giovinezza (100) | prudente | lupenaro | 100.0% | 6.52 | 4.1% | 9.0% | 0.0 | 0.00 | +2.0 | -3.9 |
| giovinezza (100) | prudente | janara | 100.0% | 5.00 | 0.0% | 0.0% | 2.0 | 0.00 | +0.5 | -8.0 |
| giovinezza (100) | prudente | pantafica | 100.0% | 6.27 | 1.5% | 5.0% | 0.0 | 2.95 | +1.8 | -6.5 |
| giovinezza (100) | prudente | munaciello_offeso | 100.0% | 5.65 | 3.7% | 8.0% | 0.0 | 0.00 | +1.2 | -4.3 |
| giovinezza (100) | aggressiva | lupenaro | 100.0% | 4.59 | 9.9% | 15.0% | 0.0 | 0.00 | +0.1 | 0 |
| giovinezza (100) | aggressiva | janara | 100.0% | 4.17 | 0.0% | 0.0% | 14.0 | 0.00 | 0 | -8.0 |
| giovinezza (100) | aggressiva | pantafica | 100.0% | 4.66 | 8.1% | 13.0% | 0.0 | 2.08 | +0.2 | 0 |
| giovinezza (100) | aggressiva | munaciello_offeso | 100.0% | 4.94 | 7.2% | 14.0% | 0.0 | 0.00 | +0.4 | -0.8 |
| eta adulta (85) | ragionevole | lupenaro | 100.0% | 3.75 | 12.3% | 12.9% | 0.0 | 0.00 | 0 | +0.3 |
| eta adulta (85) | ragionevole | janara | 100.0% | 3.98 | 0.0% | 0.0% | 1.0 | 0.00 | 0 | -8.0 |
| eta adulta (85) | ragionevole | pantafica | 100.0% | 3.85 | 11.4% | 17.6% | 0.0 | 1.63 | 0 | 0 |
| eta adulta (85) | ragionevole | munaciello_offeso | 100.0% | 4.08 | 9.5% | 16.5% | 0.0 | 0.00 | 0 | 0 |
| eta adulta (85) | prudente | lupenaro | 100.0% | 6.72 | 1.4% | 4.7% | 0.0 | 0.00 | +2.2 | -6.6 |
| eta adulta (85) | prudente | janara | 100.0% | 4.59 | 0.0% | 0.0% | 0.9 | 0.00 | +0.1 | -8.0 |
| eta adulta (85) | prudente | pantafica | 100.0% | 5.74 | 0.5% | 1.2% | 0.0 | 2.62 | +1.2 | -7.5 |
| eta adulta (85) | prudente | munaciello_offeso | 100.0% | 5.31 | 1.8% | 5.9% | 0.0 | 0.00 | +0.8 | -6.2 |
| eta adulta (85) | aggressiva | lupenaro | 100.0% | 3.75 | 12.3% | 12.9% | 0.0 | 0.00 | 0 | +0.3 |
| eta adulta (85) | aggressiva | janara | 100.0% | 3.35 | 0.0% | 0.0% | 14.3 | 0.00 | -0.2 | -8.0 |
| eta adulta (85) | aggressiva | pantafica | 100.0% | 3.85 | 11.4% | 17.6% | 0.0 | 1.63 | 0 | 0 |
| eta adulta (85) | aggressiva | munaciello_offeso | 100.0% | 3.94 | 11.7% | 20.0% | 0.0 | 0.00 | 0 | 0 |
| vecchiaia (60) | ragionevole | lupenaro | 100.0% | 3.71 | 11.6% | 13.3% | 0.0 | 0.00 | 0 | 0 |
| vecchiaia (60) | ragionevole | janara | 100.0% | 3.66 | 0.0% | 0.0% | 0.3 | 0.00 | 0 | -8.0 |
| vecchiaia (60) | ragionevole | pantafica | 100.0% | 3.58 | 12.8% | 20.0% | 0.0 | 1.62 | 0 | +0.8 |
| vecchiaia (60) | ragionevole | munaciello_offeso | 100.0% | 3.62 | 13.9% | 23.3% | 0.0 | 0.00 | 0 | +1.9 |
| vecchiaia (60) | prudente | lupenaro | 100.0% | 6.57 | 0.9% | 3.3% | 0.0 | 0.00 | +2.1 | -7.1 |
| vecchiaia (60) | prudente | janara | 100.0% | 4.29 | 0.0% | 0.0% | 0.2 | 0.00 | 0 | -8.0 |
| vecchiaia (60) | prudente | pantafica | 100.0% | 5.24 | 0.1% | 0.0% | 0.0 | 2.38 | +0.7 | -7.9 |
| vecchiaia (60) | prudente | munaciello_offeso | 100.0% | 4.87 | 0.7% | 3.3% | 0.0 | 0.00 | +0.4 | -7.3 |
| vecchiaia (60) | aggressiva | lupenaro | 100.0% | 3.25 | 23.4% | 30.0% | 0.0 | 0.00 | -0.2 | +11.4 |
| vecchiaia (60) | aggressiva | janara | 100.0% | 3.02 | 0.0% | 0.0% | 14.3 | 0.00 | -0.5 | -8.0 |
| vecchiaia (60) | aggressiva | pantafica | 100.0% | 3.34 | 18.0% | 28.3% | 0.0 | 1.44 | -0.2 | +6.0 |
| vecchiaia (60) | aggressiva | munaciello_offeso | 100.0% | 3.38 | 19.5% | 35.0% | 0.0 | 0.00 | -0.1 | +7.5 |

## Forma toccata — mazzo "meta" (generazione 3, 15 carte)

Obiettivi: 4-5 turni, 10-15% di vita persa.

| Età (vita) | Strategia | Nemico | Vittorie | Turni medi | Vita persa media | Vita persa 90° perc. | Casa persa | Fattura a fine | Δ turni | Δ vita |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| giovinezza (100) | ragionevole | lupenaro | 100.0% | 4.02 | 15.0% | 22.0% | 0.0 | 0.00 | 0 | +0.0 |
| giovinezza (100) | ragionevole | janara | 100.0% | 4.20 | 0.0% | 0.0% | 4.9 | 0.00 | 0 | -10.0 |
| giovinezza (100) | ragionevole | pantafica | 100.0% | 4.45 | 14.7% | 22.0% | 0.0 | 1.24 | 0 | 0 |
| giovinezza (100) | ragionevole | munaciello_offeso | 100.0% | 3.85 | 12.3% | 21.0% | 0.0 | 0.00 | -0.1 | 0 |
| giovinezza (100) | prudente | lupenaro | 100.0% | 6.05 | 8.8% | 15.0% | 0.0 | 0.00 | +1.0 | -1.2 |
| giovinezza (100) | prudente | janara | 100.0% | 4.38 | 0.0% | 0.0% | 4.6 | 0.00 | 0 | -10.0 |
| giovinezza (100) | prudente | pantafica | 100.0% | 6.09 | 4.0% | 10.0% | 0.0 | 1.57 | +1.1 | -6.0 |
| giovinezza (100) | prudente | munaciello_offeso | 100.0% | 4.83 | 6.1% | 13.0% | 0.0 | 0.00 | 0 | -3.9 |
| giovinezza (100) | aggressiva | lupenaro | 100.0% | 3.88 | 13.9% | 22.0% | 0.0 | 0.00 | -0.1 | 0 |
| giovinezza (100) | aggressiva | janara | 100.0% | 3.31 | 0.0% | 0.0% | 14.4 | 0.00 | -0.7 | -10.0 |
| giovinezza (100) | aggressiva | pantafica | 100.0% | 4.25 | 13.7% | 20.0% | 0.0 | 1.10 | 0 | 0 |
| giovinezza (100) | aggressiva | munaciello_offeso | 100.0% | 3.76 | 11.3% | 21.0% | 0.0 | 0.00 | -0.2 | 0 |
| eta adulta (85) | ragionevole | lupenaro | 100.0% | 3.51 | 19.9% | 25.9% | 0.0 | 0.00 | -0.5 | +4.9 |
| eta adulta (85) | ragionevole | janara | 100.0% | 3.84 | 0.0% | 0.0% | 2.9 | 0.00 | -0.2 | -10.0 |
| eta adulta (85) | ragionevole | pantafica | 100.0% | 3.92 | 19.2% | 28.2% | 0.0 | 1.05 | -0.1 | +4.2 |
| eta adulta (85) | ragionevole | munaciello_offeso | 100.0% | 3.82 | 10.6% | 16.5% | 0.0 | 0.00 | -0.2 | 0 |
| eta adulta (85) | prudente | lupenaro | 100.0% | 6.16 | 6.6% | 14.1% | 0.0 | 0.00 | +1.2 | -3.4 |
| eta adulta (85) | prudente | janara | 100.0% | 4.18 | 0.0% | 0.0% | 2.6 | 0.00 | 0 | -10.0 |
| eta adulta (85) | prudente | pantafica | 100.0% | 5.60 | 2.6% | 7.1% | 0.0 | 1.34 | +0.6 | -7.4 |
| eta adulta (85) | prudente | munaciello_offeso | 100.0% | 4.65 | 4.4% | 11.8% | 0.0 | 0.00 | 0 | -5.6 |
| eta adulta (85) | aggressiva | lupenaro | 100.0% | 3.41 | 18.6% | 25.9% | 0.0 | 0.00 | -0.6 | +3.6 |
| eta adulta (85) | aggressiva | janara | 100.0% | 2.85 | 0.0% | 0.0% | 13.2 | 0.00 | -1.1 | -10.0 |
| eta adulta (85) | aggressiva | pantafica | 100.0% | 3.76 | 17.1% | 24.7% | 0.0 | 0.96 | -0.2 | +2.1 |
| eta adulta (85) | aggressiva | munaciello_offeso | 100.0% | 3.30 | 14.4% | 24.7% | 0.0 | 0.00 | -0.7 | 0 |
| vecchiaia (60) | ragionevole | lupenaro | 100.0% | 3.96 | 11.0% | 16.7% | 0.0 | 0.00 | -0.0 | 0 |
| vecchiaia (60) | ragionevole | janara | 100.0% | 3.61 | 0.0% | 0.0% | 1.7 | 0.00 | -0.4 | -10.0 |
| vecchiaia (60) | ragionevole | pantafica | 100.0% | 4.04 | 16.3% | 26.7% | 0.0 | 1.14 | 0 | +1.3 |
| vecchiaia (60) | ragionevole | munaciello_offeso | 100.0% | 3.56 | 12.3% | 23.3% | 0.0 | 0.00 | -0.4 | 0 |
| vecchiaia (60) | prudente | lupenaro | 100.0% | 6.30 | 5.8% | 15.0% | 0.0 | 0.00 | +1.3 | -4.2 |
| vecchiaia (60) | prudente | janara | 100.0% | 3.98 | 0.0% | 0.0% | 1.2 | 0.00 | -0.0 | -10.0 |
| vecchiaia (60) | prudente | pantafica | 100.0% | 5.30 | 1.4% | 6.7% | 0.0 | 1.22 | +0.3 | -8.6 |
| vecchiaia (60) | prudente | munaciello_offeso | 100.0% | 4.44 | 3.2% | 11.7% | 0.0 | 0.00 | 0 | -6.8 |
| vecchiaia (60) | aggressiva | lupenaro | 100.0% | 3.14 | 29.4% | 36.7% | 0.0 | 0.00 | -0.9 | +14.4 |
| vecchiaia (60) | aggressiva | janara | 100.0% | 2.60 | 0.0% | 0.0% | 11.7 | 0.00 | -1.4 | -10.0 |
| vecchiaia (60) | aggressiva | pantafica | 100.0% | 3.42 | 24.6% | 40.0% | 0.0 | 0.90 | -0.6 | +9.6 |
| vecchiaia (60) | aggressiva | munaciello_offeso | 100.0% | 2.94 | 20.3% | 35.0% | 0.0 | 0.00 | -1.1 | +5.3 |

## Forma divorata — mazzo "fine" (generazione 5, 18 carte)

Obiettivi: 4-5 turni, 12-18% di vita persa.

| Età (vita) | Strategia | Nemico | Vittorie | Turni medi | Vita persa media | Vita persa 90° perc. | Casa persa | Fattura a fine | Δ turni | Δ vita | Colpo potenziato (medio / max) | Sconfitte per il colpo potenziato |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| giovinezza (100) | ragionevole | lupenaro | 100.0% | 3.71 | 14.0% | 20.0% | 0.0 | 0.00 | -0.3 | 0 | 13.1 / 29 | 0.0% |
| giovinezza (100) | ragionevole | janara | 100.0% | 3.96 | 0.0% | 0.0% | 11.1 | 0.00 | -0.0 | -12.0 | 0.0 / 0 | 0.0% |
| giovinezza (100) | ragionevole | pantafica | 100.0% | 4.47 | 15.9% | 25.0% | 0.0 | 1.16 | 0 | 0 | 7.6 / 17 | 0.0% |
| giovinezza (100) | ragionevole | munaciello_offeso | 100.0% | 3.94 | 15.9% | 26.0% | 0.0 | 0.00 | -0.1 | 0 | 9.8 / 20 | 0.0% |
| giovinezza (100) | prudente | lupenaro | 100.0% | 4.96 | 12.6% | 23.0% | 0.0 | 0.00 | 0 | 0 | 14.2 / 29 | 0.0% |
| giovinezza (100) | prudente | janara | 100.0% | 4.05 | 0.0% | 0.0% | 12.3 | 0.00 | 0 | -12.0 | 0.0 / 0 | 0.0% |
| giovinezza (100) | prudente | pantafica | 100.0% | 5.58 | 11.9% | 21.0% | 0.0 | 1.26 | +0.6 | -0.1 | 5.4 / 17 | 0.0% |
| giovinezza (100) | prudente | munaciello_offeso | 100.0% | 4.47 | 15.8% | 27.0% | 0.0 | 0.00 | 0 | 0 | 8.1 / 20 | 0.0% |
| giovinezza (100) | aggressiva | lupenaro | 100.0% | 3.71 | 12.5% | 22.0% | 0.0 | 0.00 | -0.3 | 0 | 18.3 / 29 | 0.0% |
| giovinezza (100) | aggressiva | janara | 100.0% | 3.22 | 0.0% | 0.0% | 18.8 | 0.00 | -0.8 | -12.0 | 0.0 / 0 | 0.0% |
| giovinezza (100) | aggressiva | pantafica | 100.0% | 4.07 | 19.4% | 30.0% | 0.0 | 0.87 | 0 | +1.4 | 11.5 / 17 | 0.0% |
| giovinezza (100) | aggressiva | munaciello_offeso | 100.0% | 3.58 | 19.0% | 33.0% | 0.0 | 0.00 | -0.4 | +1.0 | 12.8 / 20 | 0.0% |
| eta adulta (85) | ragionevole | lupenaro | 100.0% | 3.34 | 18.7% | 23.5% | 0.0 | 0.00 | -0.7 | +0.7 | 12.9 / 22 | 0.0% |
| eta adulta (85) | ragionevole | janara | 100.0% | 3.71 | 0.0% | 0.0% | 8.0 | 0.00 | -0.3 | -12.0 | 0.0 / 0 | 0.0% |
| eta adulta (85) | ragionevole | pantafica | 100.0% | 4.20 | 17.5% | 27.1% | 0.0 | 1.09 | 0 | 0 | 7.1 / 17 | 0.0% |
| eta adulta (85) | ragionevole | munaciello_offeso | 100.0% | 3.89 | 15.6% | 27.1% | 0.0 | 0.00 | -0.1 | 0 | 8.3 / 20 | 0.0% |
| eta adulta (85) | prudente | lupenaro | 100.0% | 4.81 | 10.6% | 21.2% | 0.0 | 0.00 | 0 | -1.4 | 11.3 / 29 | 0.0% |
| eta adulta (85) | prudente | janara | 100.0% | 3.94 | 0.0% | 0.0% | 9.2 | 0.00 | -0.1 | -12.0 | 0.0 / 0 | 0.0% |
| eta adulta (85) | prudente | pantafica | 100.0% | 5.27 | 9.7% | 20.0% | 0.0 | 1.10 | +0.3 | -2.3 | 3.9 / 17 | 0.0% |
| eta adulta (85) | prudente | munaciello_offeso | 100.0% | 4.45 | 15.4% | 27.1% | 0.0 | 0.00 | 0 | 0 | 6.5 / 20 | 0.0% |
| eta adulta (85) | aggressiva | lupenaro | 100.0% | 3.29 | 14.8% | 23.5% | 0.0 | 0.00 | -0.7 | 0 | 17.0 / 27 | 0.0% |
| eta adulta (85) | aggressiva | janara | 100.0% | 2.78 | 0.0% | 0.0% | 16.9 | 0.00 | -1.2 | -12.0 | 0.0 / 0 | 0.0% |
| eta adulta (85) | aggressiva | pantafica | 100.0% | 3.65 | 22.4% | 35.3% | 0.0 | 0.79 | -0.3 | +4.4 | 12.9 / 17 | 0.0% |
| eta adulta (85) | aggressiva | munaciello_offeso | 100.0% | 3.18 | 21.7% | 38.8% | 0.0 | 0.00 | -0.8 | +3.7 | 14.5 / 20 | 0.0% |
| vecchiaia (60) | ragionevole | lupenaro | 100.0% | 4.06 | 9.1% | 25.0% | 0.0 | 0.00 | 0 | -2.9 | 11.7 / 29 | 0.0% |
| vecchiaia (60) | ragionevole | janara | 100.0% | 3.60 | 0.0% | 0.0% | 6.3 | 0.00 | -0.4 | -12.0 | 0.0 / 0 | 0.0% |
| vecchiaia (60) | ragionevole | pantafica | 100.0% | 4.21 | 21.1% | 35.0% | 0.0 | 1.10 | 0 | +3.1 | 5.0 / 17 | 0.0% |
| vecchiaia (60) | ragionevole | munaciello_offeso | 100.0% | 3.96 | 17.2% | 31.7% | 0.0 | 0.00 | -0.0 | 0 | 6.2 / 20 | 0.0% |
| vecchiaia (60) | prudente | lupenaro | 100.0% | 4.59 | 11.6% | 28.3% | 0.0 | 0.00 | 0 | -0.4 | 10.3 / 27 | 0.0% |
| vecchiaia (60) | prudente | janara | 100.0% | 3.93 | 0.0% | 0.0% | 6.7 | 0.00 | -0.1 | -12.0 | 0.0 / 0 | 0.0% |
| vecchiaia (60) | prudente | pantafica | 100.0% | 5.13 | 9.6% | 21.7% | 0.0 | 0.94 | +0.1 | -2.4 | 2.7 / 17 | 0.0% |
| vecchiaia (60) | prudente | munaciello_offeso | 100.0% | 4.46 | 17.5% | 31.7% | 0.0 | 0.00 | 0 | 0 | 5.1 / 20 | 0.0% |
| vecchiaia (60) | aggressiva | lupenaro | 100.0% | 2.95 | 21.9% | 33.3% | 0.0 | 0.00 | -1.0 | +3.9 | 17.7 / 26 | 0.0% |
| vecchiaia (60) | aggressiva | janara | 100.0% | 2.54 | 0.0% | 0.0% | 15.3 | 0.00 | -1.5 | -12.0 | 0.0 / 0 | 0.0% |
| vecchiaia (60) | aggressiva | pantafica | 100.0% | 3.32 | 30.4% | 50.0% | 0.0 | 0.67 | -0.7 | +12.4 | 14.0 / 17 | 0.0% |
| vecchiaia (60) | aggressiva | munaciello_offeso | 100.0% | 2.88 | 29.6% | 55.0% | 0.0 | 0.00 | -1.1 | +11.6 | 15.8 / 20 | 0.0% |

## Osservazioni
Verifica della proposta T2.13: la proposta e il ragionamento sono nel diario (`docs/DIARIO.md`, Tappa 2d). In breve: forma base dentro gli obiettivi per Lupenaro, Pantafica e Munaciello; toccata e divorata vicine (al massimo 0,3 turni e 2 punti di vita fuori), con i moltiplicatori di vita delle forme a 1,0.
