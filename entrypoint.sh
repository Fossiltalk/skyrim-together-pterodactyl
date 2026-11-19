#!/bin/bash
cd /home/container || exit 1
mkdir -p config Data logs

echo "Skyrim Together Reborn server ${ST_VERSION}"
[ -f Data/loadorder.txt ] || echo "Note: Data/loadorder.txt not found (only needed when mod check is on)."

# Pterodactyl passes the startup command in STARTUP with {{VAR}} placeholders.
MODIFIED_STARTUP=$(echo -e "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo "container@pterodactyl~ ${MODIFIED_STARTUP}"
eval exec ${MODIFIED_STARTUP}
