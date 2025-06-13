#!/bin/bash

# Vérifie qu'un fichier log est passé en paramètre
if [ -z "$1" ]; then
  echo "Usage : $0 <fichier_log>"
  exit 1
fi

LOG_FILE="$1"
ARCHIVE_FILE="${LOG_FILE%.*}.archive.log"  # Exemple : rights.log -> rights.archive.log
TEMP_FILE="${LOG_FILE}.tmp"
TEMP_ARCHIVE="${ARCHIVE_FILE}.tmp"

# Vérifie que le fichier existe
if [ ! -f "$LOG_FILE" ]; then
  echo "Erreur : le fichier '$LOG_FILE' n'existe pas."
  exit 1
fi

# Dates limites
DATE_LIMITE_7DAYS=$(date -d "7 days ago" +%Y-%m-%d)
DATE_LIMITE_3MONTHS=$(date -d "3 months ago" +%Y-%m-%d)

# 1) Traitement du fichier log : déplacer les lignes plus vieilles que 7 jours vers l'archive

# Fichier temporaire vide
> "$TEMP_FILE"

while IFS= read -r ligne; do
  DATE_LIGNE=${ligne:0:10}  # on suppose que la date est en début de ligne au format YYYY-MM-DD

  # Vérifie si la date est au bon format
  if [[ "$DATE_LIGNE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    if [[ "$DATE_LIGNE" < "$DATE_LIMITE_7DAYS" ]]; then
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

echo "Archivage terminé : logs avant $DATE_LIMITE_7DAYS déplacés vers $ARCHIVE_FILE."

# 2) Suppression dans le fichier d'archive des lignes plus vieilles que 3 mois

if [ -f "$ARCHIVE_FILE" ]; then
  > "$TEMP_ARCHIVE"
  while IFS= read -r ligne; do
    DATE_LIGNE=${ligne:0:10}
    if [[ "$DATE_LIGNE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
      if [[ "$DATE_LIGNE" > "$DATE_LIMITE_3MONTHS" ]]; then
        echo "$ligne" >> "$TEMP_ARCHIVE"
      fi
    else
      # Ligne sans date valide, on la conserve
      echo "$ligne" >> "$TEMP_ARCHIVE"
    fi
  done < "$ARCHIVE_FILE"

  # Remplace le fichier archive par la version nettoyée
  mv "$TEMP_ARCHIVE" "$ARCHIVE_FILE"

  echo "Nettoyage de l'archive terminé : lignes avant $DATE_LIMITE_3MONTHS supprimées."
else
  echo "Fichier d'archive '$ARCHIVE_FILE' introuvable, nettoyage ignoré."
fi
