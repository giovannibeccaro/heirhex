# testi/

`testi.csv` contiene tutti i testi del gioco (colonne `keys,it,en`). Nel codice e nei dati compaiono solo le **chiavi**.

Godot importa il CSV come traduzione (genera i file `.translation` accanto al CSV) e `tr("chiave")` restituisce il testo nella lingua attiva.
Il codice non compone frasi (D41, D42): i modelli di frase stanno qui, uno per lingua.
