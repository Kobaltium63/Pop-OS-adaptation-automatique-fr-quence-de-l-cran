#!/bin/bash
# Script de désinstallation : uninstall-power-refresh.sh
# Supprime l'installation du changement automatique 60/144 Hz selon l'état du chargeur.
#
# Cette version correspond à l'installation basée sur :
#   - /usr/local/bin/power-refresh-cosmic.sh
#   - /etc/udev/rules.d/99-power-refresh-cosmic.rules

set -e

SCRIPT_PATH="/usr/local/bin/power-refresh-cosmic.sh"
RULE_PATH="/etc/udev/rules.d/99-power-refresh-cosmic.rules"

echo "=== Désinstallation du changement automatique de fréquence d'écran ==="

# 1. Supprimer la règle udev
echo "[1/3] Suppression de la règle udev"
if [ -f "$RULE_PATH" ]; then
    sudo rm -f "$RULE_PATH"
    echo "  ✓ Règle supprimée : $RULE_PATH"
else
    echo "  - Règle absente : $RULE_PATH"
fi

# 2. Supprimer le script de changement de fréquence
echo "[2/3] Suppression du script de changement de fréquence"
if [ -f "$SCRIPT_PATH" ]; then
    sudo rm -f "$SCRIPT_PATH"
    echo "  ✓ Script supprimé : $SCRIPT_PATH"
else
    echo "  - Script absent : $SCRIPT_PATH"
fi

# 3. Recharger udev
echo "[3/3] Rechargement des règles udev"
sudo udevadm control --reload-rules

echo ""
echo "=== Désinstallation terminée ==="
echo ""
echo "Si un changement de fréquence reste visible après désinstallation :"
echo "  - débranche / rebranche le chargeur,"
echo "  - reconnecte ta session,"
echo "  - ou redémarre complètement la machine."
