# data/ — i contenuti del gioco

- `generati/` — JSON prodotti da `strumenti/esporta.py` a partire da `bilanciamento.xlsx`. **Mai modificarli a mano**: si rigenerano.
- `manuali/` — JSON scritti a mano (stati, eventi, modificatori, memoria della stirpe).

Ogni file ha un campo `schema` (numero di versione). Tutto si riferisce per `id`; i testi sono chiavi di `testi/testi.csv`.
