# Report della simulazione di bilanciamento

Generato da `strumenti/simula.gd` il 2026-11-07. **Nessun numero è stato corretto: il report misura e basta.**

## Come
- D65: ogni forma della fattura si misura contro il **mazzo di riferimento della sua fase** (scheda Mazzi di riferimento) e i suoi **obiettivi** (scheda Forme fattura, colonne F-J). Carte con livello: evoluzione "Più forte" una o due volte; contano come ereditate (per le Radici).
- 1000 combattimenti per riga (semi da 1 a 1000), un nemico normale alla volta, vita piena a inizio combattimento, casa 35 in tutte le età.
- Strategie (`core/simulazione/giocatore_automatico.gd`): **ragionevole** = prima le carte che preparano (pesca, Radici); si difende solo da un colpo che supera il 15% della vita massima o che sarebbe letale, e solo finché resta sopra quella soglia; se può uccidere il nemico in questo turno attacca. **Prudente** = blocca ogni danno annunciato prima di attaccare. **Aggressiva** = non si difende mai prima di attaccare.
- Gli obiettivi si confrontano con la strategia **ragionevole** (D65: "con un gioco ragionevole"). Δ = distanza dall'intervallo obiettivo (0 = dentro; turni in turni, vita in punti percentuali). Un obiettivo di turni esatto ("4") vale ±0,5.
- Tempo di calcolo: 210 s.

## Riepilogo (strategia ragionevole, media sulle tre età)

| Forma | Mazzo | Obiettivo turni | Obiettivo vita persa | Nemico | Turni | Vita persa | Δ turni | Δ vita | Dentro? |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| base | inizio | 3.5-4.5 | 8-12% | lupenaro | 3.61 | 17.7% | 0 | +5.7 | no |
| base | inizio | 3.5-4.5 | 8-12% | janara | 4.50 | 0.0% | 0 | -8.0 | no |
| base | inizio | 3.5-4.5 | 8-12% | pantafica | 3.52 | 10.1% | 0 | 0 | sì |
| base | inizio | 3.5-4.5 | 8-12% | munaciello_offeso | 3.61 | 4.3% | 0 | -3.7 | no |
| toccata | meta | 4-5 | 10-15% | lupenaro | 5.34 | 35.1% | +0.3 | +20.1 | no |
| toccata | meta | 4-5 | 10-15% | janara | 5.20 | 0.0% | +0.2 | -10.0 | no |
| toccata | meta | 4-5 | 10-15% | pantafica | 4.58 | 18.3% | 0 | +3.3 | no |
| toccata | meta | 4-5 | 10-15% | munaciello_offeso | 4.09 | 11.9% | 0 | 0 | sì |
| divorata | fine | 4-5 | 12-18% | lupenaro | 6.10 | 76.6% | +1.1 | +58.6 | no |
| divorata | fine | 4-5 | 12-18% | janara | 6.17 | 0.0% | +1.2 | -12.0 | no |
| divorata | fine | 4-5 | 12-18% | pantafica | 5.89 | 41.4% | +0.9 | +23.4 | no |
| divorata | fine | 4-5 | 12-18% | munaciello_offeso | 5.34 | 23.9% | +0.3 | +5.9 | no |

## Forma base — mazzo "inizio" (generazione 1, 10 carte)

Obiettivi: 3.5-4.5 turni, 8-12% di vita persa.

| Età (vita) | Strategia | Nemico | Vittorie | Turni medi | Vita persa media | Vita persa 90° perc. | Casa persa | Fattura a fine | Δ turni | Δ vita |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| giovinezza (100) | ragionevole | lupenaro | 100.0% | 4.11 | 13.3% | 19.0% | 0.0 | 0.00 | 0 | +1.3 |
| giovinezza (100) | ragionevole | janara | 100.0% | 5.07 | 0.0% | 0.0% | 2.6 | 0.00 | +0.6 | -8.0 |
| giovinezza (100) | ragionevole | pantafica | 100.0% | 4.05 | 8.3% | 13.0% | 0.0 | 1.73 | 0 | 0 |
| giovinezza (100) | ragionevole | munaciello_offeso | 100.0% | 4.29 | 2.6% | 8.0% | 0.0 | 0.00 | 0 | -5.4 |
| giovinezza (100) | prudente | lupenaro | 100.0% | 6.88 | 17.3% | 23.0% | 0.0 | 0.00 | +2.4 | +5.3 |
| giovinezza (100) | prudente | janara | 100.0% | 5.39 | 0.0% | 0.0% | 2.0 | 0.00 | +0.9 | -8.0 |
| giovinezza (100) | prudente | pantafica | 100.0% | 5.83 | 2.0% | 6.0% | 0.0 | 2.76 | +1.3 | -6.0 |
| giovinezza (100) | prudente | munaciello_offeso | 100.0% | 4.61 | 0.5% | 3.0% | 0.0 | 0.00 | +0.1 | -7.5 |
| giovinezza (100) | aggressiva | lupenaro | 100.0% | 3.99 | 14.8% | 19.0% | 0.0 | 0.00 | 0 | +2.8 |
| giovinezza (100) | aggressiva | janara | 100.0% | 4.48 | 0.0% | 0.0% | 14.2 | 0.00 | 0 | -8.0 |
| giovinezza (100) | aggressiva | pantafica | 100.0% | 4.05 | 8.3% | 13.0% | 0.0 | 1.73 | 0 | 0 |
| giovinezza (100) | aggressiva | munaciello_offeso | 100.0% | 4.29 | 2.6% | 8.0% | 0.0 | 0.00 | 0 | -5.4 |
| eta adulta (85) | ragionevole | lupenaro | 100.0% | 3.52 | 15.4% | 18.8% | 0.0 | 0.00 | 0 | +3.4 |
| eta adulta (85) | ragionevole | janara | 100.0% | 4.46 | 0.0% | 0.0% | 1.3 | 0.00 | 0 | -8.0 |
| eta adulta (85) | ragionevole | pantafica | 100.0% | 3.38 | 8.8% | 14.1% | 0.0 | 1.49 | -0.1 | 0 |
| eta adulta (85) | ragionevole | munaciello_offeso | 100.0% | 3.43 | 4.8% | 11.8% | 0.0 | 0.00 | -0.1 | -3.2 |
| eta adulta (85) | prudente | lupenaro | 100.0% | 7.96 | 15.2% | 23.5% | 0.0 | 0.00 | +3.5 | +3.2 |
| eta adulta (85) | prudente | janara | 100.0% | 5.01 | 0.0% | 0.0% | 1.0 | 0.00 | +0.5 | -8.0 |
| eta adulta (85) | prudente | pantafica | 100.0% | 5.41 | 0.8% | 2.4% | 0.0 | 2.49 | +0.9 | -7.2 |
| eta adulta (85) | prudente | munaciello_offeso | 100.0% | 4.16 | 0.1% | 0.0% | 0.0 | 0.00 | 0 | -7.9 |
| eta adulta (85) | aggressiva | lupenaro | 100.0% | 3.31 | 20.9% | 22.4% | 0.0 | 0.00 | -0.2 | +8.9 |
| eta adulta (85) | aggressiva | janara | 100.0% | 3.50 | 0.0% | 0.0% | 15.1 | 0.00 | 0 | -8.0 |
| eta adulta (85) | aggressiva | pantafica | 100.0% | 3.30 | 10.4% | 17.6% | 0.0 | 1.41 | -0.2 | 0 |
| eta adulta (85) | aggressiva | munaciello_offeso | 100.0% | 3.43 | 4.8% | 11.8% | 0.0 | 0.00 | -0.1 | -3.2 |
| vecchiaia (60) | ragionevole | lupenaro | 100.0% | 3.20 | 24.5% | 26.7% | 0.0 | 0.00 | -0.3 | +12.5 |
| vecchiaia (60) | ragionevole | janara | 100.0% | 3.97 | 0.0% | 0.0% | 0.4 | 0.00 | 0 | -8.0 |
| vecchiaia (60) | ragionevole | pantafica | 100.0% | 3.13 | 13.3% | 23.3% | 0.0 | 1.38 | -0.4 | +1.3 |
| vecchiaia (60) | ragionevole | munaciello_offeso | 100.0% | 3.11 | 5.5% | 10.0% | 0.0 | 0.00 | -0.4 | -2.5 |
| vecchiaia (60) | prudente | lupenaro | 100.0% | 7.75 | 15.1% | 23.3% | 0.0 | 0.00 | +3.3 | +3.1 |
| vecchiaia (60) | prudente | janara | 100.0% | 4.63 | 0.0% | 0.0% | 0.3 | 0.00 | +0.1 | -8.0 |
| vecchiaia (60) | prudente | pantafica | 100.0% | 5.04 | 0.1% | 0.0% | 0.0 | 2.33 | +0.5 | -7.9 |
| vecchiaia (60) | prudente | munaciello_offeso | 100.0% | 3.90 | 0.0% | 0.0% | 0.0 | 0.00 | 0 | -8.0 |
| vecchiaia (60) | aggressiva | lupenaro | 100.0% | 2.98 | 34.5% | 43.3% | 0.0 | 0.00 | -0.5 | +22.5 |
| vecchiaia (60) | aggressiva | janara | 100.0% | 3.12 | 0.0% | 0.0% | 14.9 | 0.00 | -0.4 | -8.0 |
| vecchiaia (60) | aggressiva | pantafica | 100.0% | 3.01 | 17.8% | 28.3% | 0.0 | 1.31 | -0.5 | +5.8 |
| vecchiaia (60) | aggressiva | munaciello_offeso | 100.0% | 3.05 | 9.8% | 21.7% | 0.0 | 0.00 | -0.5 | 0 |

## Forma toccata — mazzo "meta" (generazione 3, 15 carte)

Obiettivi: 4-5 turni, 10-15% di vita persa.

| Età (vita) | Strategia | Nemico | Vittorie | Turni medi | Vita persa media | Vita persa 90° perc. | Casa persa | Fattura a fine | Δ turni | Δ vita |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| giovinezza (100) | ragionevole | lupenaro | 100.0% | 5.45 | 34.4% | 45.0% | 0.0 | 0.00 | +0.4 | +19.4 |
| giovinezza (100) | ragionevole | janara | 100.0% | 5.65 | 0.0% | 0.0% | 9.7 | 0.00 | +0.7 | -10.0 |
| giovinezza (100) | ragionevole | pantafica | 100.0% | 4.86 | 16.9% | 25.0% | 0.0 | 1.35 | 0 | +1.9 |
| giovinezza (100) | ragionevole | munaciello_offeso | 100.0% | 4.39 | 10.7% | 19.0% | 0.0 | 0.00 | 0 | 0 |
| giovinezza (100) | prudente | lupenaro | 100.0% | 6.97 | 37.3% | 47.0% | 0.0 | 0.00 | +2.0 | +22.3 |
| giovinezza (100) | prudente | janara | 100.0% | 6.02 | 0.0% | 0.0% | 8.8 | 0.00 | +1.0 | -10.0 |
| giovinezza (100) | prudente | pantafica | 100.0% | 6.70 | 9.2% | 17.0% | 0.0 | 1.72 | +1.7 | -0.8 |
| giovinezza (100) | prudente | munaciello_offeso | 100.0% | 5.47 | 4.3% | 10.0% | 0.0 | 0.00 | +0.5 | -5.7 |
| giovinezza (100) | aggressiva | lupenaro | 100.0% | 4.45 | 35.2% | 49.0% | 0.0 | 0.00 | 0 | +20.2 |
| giovinezza (100) | aggressiva | janara | 100.0% | 4.63 | 0.0% | 0.0% | 21.6 | 0.00 | 0 | -10.0 |
| giovinezza (100) | aggressiva | pantafica | 100.0% | 4.25 | 19.6% | 28.0% | 0.0 | 1.10 | 0 | +4.6 |
| giovinezza (100) | aggressiva | munaciello_offeso | 100.0% | 4.27 | 9.8% | 17.0% | 0.0 | 0.00 | 0 | -0.2 |
| eta adulta (85) | ragionevole | lupenaro | 100.0% | 4.87 | 32.3% | 49.4% | 0.0 | 0.00 | 0 | +17.3 |
| eta adulta (85) | ragionevole | janara | 100.0% | 5.12 | 0.0% | 0.0% | 6.7 | 0.00 | +0.1 | -10.0 |
| eta adulta (85) | ragionevole | pantafica | 100.0% | 4.39 | 19.1% | 29.4% | 0.0 | 1.21 | 0 | +4.1 |
| eta adulta (85) | ragionevole | munaciello_offeso | 100.0% | 3.87 | 15.3% | 28.2% | 0.0 | 0.00 | -0.1 | +0.3 |
| eta adulta (85) | prudente | lupenaro | 100.0% | 7.68 | 39.1% | 50.6% | 0.0 | 0.00 | +2.7 | +24.1 |
| eta adulta (85) | prudente | janara | 100.0% | 5.82 | 0.0% | 0.0% | 5.1 | 0.00 | +0.8 | -10.0 |
| eta adulta (85) | prudente | pantafica | 100.0% | 6.58 | 6.7% | 14.1% | 0.0 | 1.54 | +1.6 | -3.3 |
| eta adulta (85) | prudente | munaciello_offeso | 100.0% | 5.11 | 2.9% | 8.2% | 0.0 | 0.00 | +0.1 | -7.1 |
| eta adulta (85) | aggressiva | lupenaro | 100.0% | 3.67 | 35.1% | 47.1% | 0.0 | 0.00 | -0.3 | +20.1 |
| eta adulta (85) | aggressiva | janara | 100.0% | 3.94 | 0.0% | 0.0% | 21.5 | 0.00 | -0.1 | -10.0 |
| eta adulta (85) | aggressiva | pantafica | 100.0% | 3.76 | 23.4% | 32.9% | 0.0 | 0.96 | -0.2 | +8.4 |
| eta adulta (85) | aggressiva | munaciello_offeso | 100.0% | 3.78 | 13.7% | 23.5% | 0.0 | 0.00 | -0.2 | 0 |
| vecchiaia (60) | ragionevole | lupenaro | 100.0% | 5.69 | 38.4% | 55.0% | 0.0 | 0.00 | +0.7 | +23.4 |
| vecchiaia (60) | ragionevole | janara | 100.0% | 4.81 | 0.0% | 0.0% | 5.0 | 0.00 | 0 | -10.0 |
| vecchiaia (60) | ragionevole | pantafica | 100.0% | 4.48 | 18.8% | 30.0% | 0.0 | 1.12 | 0 | +3.8 |
| vecchiaia (60) | ragionevole | munaciello_offeso | 100.0% | 4.00 | 9.6% | 16.7% | 0.0 | 0.00 | -0.0 | -0.4 |
| vecchiaia (60) | prudente | lupenaro | 100.0% | 8.57 | 48.5% | 66.7% | 0.0 | 0.00 | +3.6 | +33.5 |
| vecchiaia (60) | prudente | janara | 100.0% | 5.80 | 0.0% | 0.0% | 2.9 | 0.00 | +0.8 | -10.0 |
| vecchiaia (60) | prudente | pantafica | 100.0% | 6.53 | 4.7% | 13.3% | 0.0 | 1.48 | +1.5 | -5.3 |
| vecchiaia (60) | prudente | munaciello_offeso | 100.0% | 4.88 | 2.0% | 8.3% | 0.0 | 0.00 | 0 | -8.0 |
| vecchiaia (60) | aggressiva | lupenaro | 100.0% | 3.33 | 49.9% | 56.7% | 0.0 | 0.00 | -0.7 | +34.9 |
| vecchiaia (60) | aggressiva | janara | 100.0% | 3.51 | 0.0% | 0.0% | 20.4 | 0.00 | -0.5 | -10.0 |
| vecchiaia (60) | aggressiva | pantafica | 100.0% | 3.42 | 32.7% | 50.0% | 0.0 | 0.90 | -0.6 | +17.7 |
| vecchiaia (60) | aggressiva | munaciello_offeso | 100.0% | 3.41 | 20.9% | 40.0% | 0.0 | 0.00 | -0.6 | +5.9 |

## Forma divorata — mazzo "fine" (generazione 5, 18 carte)

Obiettivi: 4-5 turni, 12-18% di vita persa.

| Età (vita) | Strategia | Nemico | Vittorie | Turni medi | Vita persa media | Vita persa 90° perc. | Casa persa | Fattura a fine | Δ turni | Δ vita | Colpo potenziato (medio / max) | Sconfitte per il colpo potenziato |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| giovinezza (100) | ragionevole | lupenaro | 97.0% | 5.96 | 66.9% | 82.0% | 0.0 | 0.00 | +1.0 | +48.9 | 39.7 / 55 | 2.7% |
| giovinezza (100) | ragionevole | janara | 100.0% | 6.40 | 0.0% | 0.0% | 21.1 | 0.00 | +1.4 | -12.0 | 0.0 / 0 | 0.0% |
| giovinezza (100) | ragionevole | pantafica | 100.0% | 5.78 | 38.8% | 56.0% | 0.0 | 1.39 | +0.8 | +20.8 | 13.5 / 25 | 0.0% |
| giovinezza (100) | ragionevole | munaciello_offeso | 100.0% | 5.38 | 23.3% | 36.0% | 0.0 | 0.00 | +0.4 | +5.3 | 9.8 / 20 | 0.0% |
| giovinezza (100) | prudente | lupenaro | 89.4% | 6.71 | 73.2% | 100.0% | 0.0 | 0.00 | +1.7 | +55.2 | 40.5 / 55 | 9.8% |
| giovinezza (100) | prudente | janara | 100.0% | 6.27 | 0.0% | 0.0% | 21.3 | 0.00 | +1.3 | -12.0 | 0.0 / 0 | 0.0% |
| giovinezza (100) | prudente | pantafica | 100.0% | 6.94 | 38.3% | 55.0% | 0.0 | 1.44 | +1.9 | +20.3 | 12.7 / 25 | 0.0% |
| giovinezza (100) | prudente | munaciello_offeso | 100.0% | 5.97 | 22.4% | 34.0% | 0.0 | 0.00 | +1.0 | +4.4 | 8.3 / 20 | 0.0% |
| giovinezza (100) | aggressiva | lupenaro | 99.9% | 4.97 | 64.9% | 85.0% | 0.0 | 0.00 | 0 | +46.9 | 46.9 / 55 | 0.0% |
| giovinezza (100) | aggressiva | janara | 100.0% | 5.17 | 0.0% | 0.0% | 20.1 | 0.00 | +0.2 | -12.0 | 0.0 / 0 | 0.0% |
| giovinezza (100) | aggressiva | pantafica | 100.0% | 4.88 | 42.2% | 57.0% | 0.0 | 0.99 | 0 | +24.2 | 19.6 / 25 | 0.0% |
| giovinezza (100) | aggressiva | munaciello_offeso | 100.0% | 4.96 | 27.4% | 40.0% | 0.0 | 0.00 | 0 | +9.4 | 12.6 / 20 | 0.0% |
| eta adulta (85) | ragionevole | lupenaro | 93.3% | 6.25 | 71.9% | 92.9% | 0.0 | 0.00 | +1.2 | +53.9 | 37.9 / 55 | 5.1% |
| eta adulta (85) | ragionevole | janara | 100.0% | 6.06 | 0.0% | 0.0% | 20.4 | 0.00 | +1.1 | -12.0 | 0.0 / 0 | 0.0% |
| eta adulta (85) | ragionevole | pantafica | 100.0% | 5.60 | 41.5% | 62.4% | 0.0 | 1.35 | +0.6 | +23.5 | 11.7 / 25 | 0.0% |
| eta adulta (85) | ragionevole | munaciello_offeso | 100.0% | 5.24 | 22.8% | 36.5% | 0.0 | 0.00 | +0.2 | +4.8 | 8.3 / 20 | 0.0% |
| eta adulta (85) | prudente | lupenaro | 81.2% | 6.96 | 80.8% | 100.0% | 0.0 | 0.00 | +2.0 | +62.8 | 37.6 / 55 | 17.8% |
| eta adulta (85) | prudente | janara | 100.0% | 6.12 | 0.0% | 0.0% | 21.3 | 0.00 | +1.1 | -12.0 | 0.0 / 0 | 0.0% |
| eta adulta (85) | prudente | pantafica | 100.0% | 6.86 | 38.7% | 58.8% | 0.0 | 1.29 | +1.9 | +20.7 | 10.8 / 25 | 0.0% |
| eta adulta (85) | prudente | munaciello_offeso | 100.0% | 5.85 | 21.7% | 34.1% | 0.0 | 0.00 | +0.8 | +3.7 | 6.8 / 20 | 0.0% |
| eta adulta (85) | aggressiva | lupenaro | 94.5% | 4.29 | 59.8% | 95.3% | 0.0 | 0.00 | 0 | +41.8 | 46.4 / 55 | 3.6% |
| eta adulta (85) | aggressiva | janara | 100.0% | 4.45 | 0.0% | 0.0% | 19.4 | 0.00 | 0 | -12.0 | 0.0 / 0 | 0.0% |
| eta adulta (85) | aggressiva | pantafica | 100.0% | 4.29 | 46.3% | 64.7% | 0.0 | 0.80 | 0 | +28.3 | 21.1 / 25 | 0.0% |
| eta adulta (85) | aggressiva | munaciello_offeso | 100.0% | 4.30 | 31.4% | 47.1% | 0.0 | 0.00 | 0 | +13.4 | 14.3 / 20 | 0.0% |
| vecchiaia (60) | ragionevole | lupenaro | 53.7% | 6.08 | 90.8% | 100.0% | 0.0 | 0.00 | +1.1 | +72.8 | 35.1 / 52 | 20.3% |
| vecchiaia (60) | ragionevole | janara | 100.0% | 6.06 | 0.0% | 0.0% | 19.8 | 0.00 | +1.1 | -12.0 | 0.0 / 0 | 0.0% |
| vecchiaia (60) | ragionevole | pantafica | 99.1% | 6.30 | 43.9% | 71.7% | 0.0 | 1.19 | +1.3 | +25.9 | 9.5 / 25 | 0.9% |
| vecchiaia (60) | ragionevole | munaciello_offeso | 100.0% | 5.41 | 25.5% | 41.7% | 0.0 | 0.00 | +0.4 | +7.5 | 6.3 / 20 | 0.0% |
| vecchiaia (60) | prudente | lupenaro | 28.9% | 6.27 | 96.6% | 100.0% | 0.0 | 0.00 | +1.3 | +78.6 | 33.6 / 55 | 37.0% |
| vecchiaia (60) | prudente | janara | 100.0% | 6.05 | 0.0% | 0.0% | 20.0 | 0.00 | +1.0 | -12.0 | 0.0 / 0 | 0.0% |
| vecchiaia (60) | prudente | pantafica | 98.9% | 6.96 | 46.1% | 75.0% | 0.0 | 1.18 | +2.0 | +28.1 | 8.9 / 25 | 1.1% |
| vecchiaia (60) | prudente | munaciello_offeso | 100.0% | 5.80 | 24.4% | 41.7% | 0.0 | 0.00 | +0.8 | +6.4 | 5.3 / 20 | 0.0% |
| vecchiaia (60) | aggressiva | lupenaro | 83.8% | 3.70 | 64.6% | 100.0% | 0.0 | 0.00 | -0.3 | +46.6 | 31.7 / 47 | 16.2% |
| vecchiaia (60) | aggressiva | janara | 100.0% | 3.99 | 0.0% | 0.0% | 19.7 | 0.00 | -0.0 | -12.0 | 0.0 / 0 | 0.0% |
| vecchiaia (60) | aggressiva | pantafica | 97.6% | 3.87 | 61.4% | 85.0% | 0.0 | 0.65 | -0.1 | +43.4 | 22.0 / 25 | 2.2% |
| vecchiaia (60) | aggressiva | munaciello_offeso | 100.0% | 3.88 | 44.0% | 66.7% | 0.0 | 0.00 | -0.1 | +26.0 | 15.9 / 20 | 0.0% |

## Osservazioni
*Scritte a mano dopo l'esecuzione del 2026-11-07 (Tappa 2d, dati attuali, nessun numero cambiato). Se il report viene rigenerato, questa sezione va riscritta.*

### Contro gli obiettivi (strategia ragionevole)
1. **Forma base, mazzo "inizio"**: i turni sono nell'obiettivo per tutti (3,5-4,5). La vita persa no: Lupenaro sopra (18%; 13% in giovinezza, 15% in età adulta, 25% in vecchiaia), Pantafica dentro (10%), Munaciello sotto (4%), Janara 0%.
2. **Forma toccata, mazzo "meta"**: turni quasi tutti nell'obiettivo (4,1-5,3; Lupenaro e Janara appena sopra 5). Vita persa: Munaciello dentro (12%), Pantafica sopra (18%), **Lupenaro molto sopra (35%)**.
3. **Forma divorata, mazzo "fine"**: **tutti fuori**, e tutti dalla parte "troppo difficile": 5,3-6,2 turni (obiettivo 4-5) e vita persa 24% (Munaciello), 41% (Pantafica), **77% (Lupenaro)**, contro il 12-18%. Il Lupenaro divorato in vecchiaia si perde una volta su due (54% di vittorie); il Morso della luna da 55 chiude il 20% dei combattimenti in vecchiaia.
4. **L'ipotesi "gli altri divorati sono troppo deboli" non è confermata** con questi mazzi: contro il mazzo "fine" anche Pantafica e Munaciello divorati costano più del doppio dell'obiettivo. Il Lupenaro è il più fuori scala in ogni forma, ma non è l'unico.
5. **La Janara non toglie mai vita al giocatore** in nessuna forma: colpisce solo la casa (in media 0,4-2,6 punti su 35 in forma base, 5-10 in toccata, 20 in divorata). L'obiettivo di vita persa non la misura: serve un obiettivo sulla casa.

### Perché la divorata esce così (e un dubbio sui mazzi di riferimento)
6. **La potenza offensiva dei mazzi quasi non cresce tra "meta" e "fine"**, mentre la vita dei nemici cresce ×1,3 e ×1,6. Danno totale delle carte d'attacco diviso il numero di carte: "inizio" 40 / 10 = **4,0** per carta; "meta" 74 / 15 = **4,9**; "fine" 92 / 19 = **4,8**. Il mazzo "fine" ha più carte (19), ma quasi tutte difensive o di supporto, e solo 3 carte invecchiate.
7. **Il mazzo "fine" mi sembra debole rispetto a quello che le regole permettono**: con 3 carte che invecchiano a ogni passaggio (D43), alla generazione 5 ci sono stati fino a 12 invecchiamenti. Anche togliendo oboli, perdite al testamento e reliquie morte, 3 carte invecchiate su 12 di famiglia sono poche. Non l'ho corretto (vedi diario): segnalo che i numeri della divorata dipendono molto da questa stima.
