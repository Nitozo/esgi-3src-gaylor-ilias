#!/bin/bash

# Vérifie qu'un fichier log est passé en paramètre
if [ -z "$1" ]; then
  echo "Usage : $0 <fichier_log>"
  exit 1
fi

LOG_FILE="$1"
ARCHIVE_FILE="${LOG_FILE%.*}.archive.log"  # Exemple : rights.log -> rights.archive.log
TEMP_FILE="${LOG_FILE}.tmp"

# Vérifie que le fichier existe
if [ ! -f "$LOG_FILE" ]; then
  echo "Erreur : le fichier '$LOG_FILE' n'existe pas."
  exit 1
fi

# Date limite : logs plus vieux que 7 jours
DATE_LIMITE=$(date -d "7 days ago" +%Y-%m-%d)

# Fichier temporaire vide
> "$TEMP_FILE"

while IFS= read -r ligne; do
  DATE_LIGNE=${ligne:0:10}  # on suppose que la date est en début de ligne au format YYYY-MM-DD

  # Vérifie si la date est au bon format
  if [[ "$DATE_LIGNE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    if [[ "$DATE_LIGNE" < "$DATE_LIMITE" ]]; then
      echo "$ligne" >> "$ARCHIVE_FILE"
    else
      echo "$ligne" >> "$TEMP_FILE"
    fi
  else
    # Ligne sans date valide, on la conserve dans le fichier temporaire
    echo "$ligne" >> "$TEMP_FILE"
  fi
done < "$LOG_FILE"

# Remplace le fichier log original par la version nettoyée
mv "$TEMP_FILE" "$LOG_FILE"

echo "Archivage terminé : logs avant $DATE_LIMITE déplacés vers $ARCHIVE_FILE."
