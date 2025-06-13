#!/bin/bash

# Vérifie qu'un argument est donné
if [ -z "$1" ]; then
  echo "Usage: $0 <chemin_du_dossier>"
  exit 1
fi

chemin="$1"
logfile="modification_droits.log"

# Vérifie que le chemin est un dossier valide
if [ ! -d "$chemin" ]; then
  echo "Erreur : '$chemin' n'est pas un dossier valide."
  exit 1
fi

# Vide le fichier log au départ (optionnel, sinon commente cette ligne)
> "$logfile"

# Fonction pour obtenir les droits sous forme ls -l (ex: -rw-r--r--)
get_rights() {
  ls -ld "$1" | awk '{print $1}'
}

# Parcours tous les fichiers et traite
find "$chemin" -type f | while read -r fichier; do
  droits_avant=$(get_rights "$fichier")
  
  # Vérifie si le fichier n'a PAS déjà le droit lecture pour "others" (lecture pour all)
  # On regarde les droits des "others" (dernier caractère de rwx)
  # Ici on vérifie le droit lecture pour all en général : on vérifie si le droit lecture existe pour owner/group/others
  # Pour simplifier on vérifie si le droit lecture existe pour "others" (dernier triade)
  # Plus précis : on peut vérifier si chmod a+r est nécessaire en essayant de voir si l'utilisateur "others" a le droit lecture.
  
  # On va faire un test plus simple : test si chmod a+r est nécessaire en comparant avant/après
  
  chmod a+r "$fichier"
  droits_apres=$(get_rights "$fichier")

  if [ "$droits_avant" != "$droits_apres" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $fichier | $droits_avant -> $droits_apres" >> "$logfile"
  fi
done