#!/bin/bash

CHEMIN="$1"
LOG="rights.log"

# Parcourt tous les fichiers
find "$CHEMIN" -type f | while read -r fichier; do
    droits_avant=$(stat -c "%a" "$fichier")

    # Vérifie si "others" n'ont pas le droit de lecture
    if ! [ -r "$fichier" ]; then
        chmod a+r "$fichier"
        droits_apres=$(stat -c "%a" "$fichier")
        echo "$(date '+%Y-%m-%d %H:%M:%S') $fichier $droits_avant -> $droits_apres" >> "$LOG"
    fi
done