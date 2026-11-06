#!/bin/sh
# Esegue tutti i test GUT senza grafica. Uscita 0 = tutti verdi.
# Uso: strumenti/test.sh            (tutti i test)
#      strumenti/test.sh -gselect=test_stato.gd   (opzioni GUT in più)
# Fallisce anche se uno script non si carica (errore di sintassi): GUT da solo lo salterebbe.
cd "$(dirname "$0")/.." || exit 2
GODOT="${GODOT:-$(command -v godot || echo /Applications/Godot.app/Contents/MacOS/Godot)}"
[ -x "$GODOT" ] || GODOT=/Users/giovannibeccaro/Downloads/Godot.app/Contents/MacOS/Godot
# Importa le risorse (es. testi.csv → .translation) prima dei test
"$GODOT" --headless --path . --import >/dev/null 2>&1
USCITA_FILE=$(mktemp)
"$GODOT" --headless --path . -s res://addons/gut/gut_cmdln.gd "$@" 2>&1 | tee "$USCITA_FILE"
ESITO=$?
# Il codice d'uscita di Godot è quello prima della pipe
ESITO=$(grep -q -- "---- All tests passed! ----" "$USCITA_FILE" && echo 0 || echo 1)
if grep -qE "SCRIPT ERROR|Parse Error|Failed to load script" "$USCITA_FILE"; then
	echo "!!! Errori negli script (vedi sopra): test considerati falliti"
	ESITO=1
fi
rm -f "$USCITA_FILE"
exit "$ESITO"
