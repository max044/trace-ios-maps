#!/usr/bin/env bash
# Ajoute une région au catalogue : extrait un MBTiles vectoriel depuis le planet
# Protomaps, l'envoie en release GitHub, et affiche l'entrée catalog.json à coller.
#
# Usage : ./add-region.sh <id> "<Nom>" <minLon,minLat,maxLon,maxLat> <PLANET_PMTILES_URL>
# Ex.   : ./add-region.sh alpes-maritimes "Alpes-Maritimes" 6.6,43.4,7.7,44.4 https://build.protomaps.com/20260601.pmtiles
set -euo pipefail
ID="${1:?id}"; NAME="${2:?nom}"; BBOX="${3:?bbox minLon,minLat,maxLon,maxLat}"; PLANET="${4:?url planet pmtiles}"
OUT="/tmp/${ID}.pmtiles"; MB="/tmp/${ID}.mbtiles"

echo "→ Extraction $ID ($BBOX)…"
pmtiles extract "$PLANET" "$OUT" --bbox="$BBOX" --maxzoom=14
tile-join -o "$MB" "$OUT"
SIZE=$(( $(stat -f%z "$MB") / 1048576 ))
echo "→ Pack: $MB (${SIZE} Mo)"

echo "→ Upload en release packs-v1…"
gh release upload packs-v1 "$MB" --clobber -R max044/trace-ios-maps

cat <<EOF

Ajoute cette entrée dans catalog.json (puis git commit + push) :
    {
      "id": "${ID}",
      "name": "${NAME}",
      "bbox": [${BBOX//,/, }],
      "map": "https://github.com/max044/trace-ios-maps/releases/download/packs-v1/${ID}.mbtiles",
      "sizeMB": ${SIZE}
    }
EOF
