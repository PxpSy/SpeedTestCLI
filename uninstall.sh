#!/bin/bash
set -e

# Emplacement du lien
LINK="/usr/local/bin/speedtest"

if [ -L "$LINK" ] || [ -e "$LINK" ]; then
  echo "Suppression de 'speedtest'…"
  sudo rm -f "$LINK"
  echo "'speedtest' a été désinstallé."
else
  echo "Aucun 'speedtest' trouvé dans /usr/local/bin."
fi