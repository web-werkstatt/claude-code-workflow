#!/bin/bash
# Liste alle Dateien im Dokumentenaustausch-Ordner

EXCHANGE_DIR="${SHARED_DOCS_DIR:-$HOME/shared-docs}"

echo "=== DOKUMENTENAUSTAUSCH ==="
echo "Pfad: $EXCHANGE_DIR"
echo ""

if [ ! -d "$EXCHANGE_DIR" ]; then
    echo "FEHLER: Ordner existiert nicht!"
    exit 1
fi

echo "=== DATEIEN ==="
find "$EXCHANGE_DIR" -type f -not -name ".*" | while read file; do
    size=$(du -h "$file" | cut -f1)
    modified=$(stat -c %y "$file" | cut -d' ' -f1)
    echo "$modified  $size  ${file#$EXCHANGE_DIR/}"
done | sort -r

echo ""
echo "=== STATISTIK ==="
echo "Gesamt: $(find "$EXCHANGE_DIR" -type f -not -name ".*" | wc -l) Dateien"
echo "Groesse: $(du -sh "$EXCHANGE_DIR" | cut -f1)"
