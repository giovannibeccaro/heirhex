#!/bin/sh
# Valida i dati del gioco. Uso: strumenti/valida.sh [--correggi]
cd "$(dirname "$0")/.." || exit 2
GODOT="${GODOT:-$(command -v godot || echo /Applications/Godot.app/Contents/MacOS/Godot)}"
[ -x "$GODOT" ] || GODOT=/Users/giovannibeccaro/Downloads/Godot.app/Contents/MacOS/Godot
"$GODOT" --headless --path . --import >/dev/null 2>&1
exec "$GODOT" --headless --path . -s res://strumenti/valida.gd -- "$@"
