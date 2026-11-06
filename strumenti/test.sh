#!/bin/sh
# Esegue tutti i test GUT senza grafica. Uscita 0 = tutti verdi.
# Uso: strumenti/test.sh            (tutti i test)
#      strumenti/test.sh -gselect=test_stato.gd   (opzioni GUT in più)
set -e
cd "$(dirname "$0")/.."
GODOT="${GODOT:-$(command -v godot || echo /Applications/Godot.app/Contents/MacOS/Godot)}"
[ -x "$GODOT" ] || GODOT=/Users/giovannibeccaro/Downloads/Godot.app/Contents/MacOS/Godot
# Importa le risorse (es. testi.csv → .translation) prima dei test
"$GODOT" --headless --path . --import >/dev/null 2>&1
exec "$GODOT" --headless --path . -s res://addons/gut/gut_cmdln.gd "$@"
