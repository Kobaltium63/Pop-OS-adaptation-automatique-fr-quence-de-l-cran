#!/bin/bash
# Script d'installation : power-refresh-cosmic-auto-install.sh
# Installe le script de changement 60/144 Hz et la règle udev pour Wayland + cosmic-randr

set -e

SCRIPT_PATH="/usr/local/bin/power-refresh-cosmic.sh"
RULE_PATH="/etc/udev/rules.d/99-power-refresh-cosmic.rules"

echo "=== Installation du système automatique 60/144 Hz sur Pop!_OS Wayland ==="

# 1. Créer le script de changement de fréquence
echo "[1/3] Création du script $SCRIPT_PATH"

cat > "$SCRIPT_PATH" << 'SCRIPT_EOF'
#!/bin/bash
# Script: /usr/local/bin/power-refresh-cosmic.sh
# But: changer automatiquement 60 Hz / 144 Hz sur Wayland selon le chargeur
# Commandes:
#   cosmic-randr mode --refresh 144 eDP-1 1920 1080
#   cosmic-randr mode --refresh 60  eDP-1 1920 1080

set -e

# Configuration
OUTPUT="eDP-1"
WIDTH=1920
HEIGHT=1080
HZ_ON_AC=144
HZ_ON_BATTERY=60

# Déterminer l'outil pour lire l'alimentation
# On cherche AC/online ou Mains/online
if [ -f /sys/class/power_supply/AC/online ]; then
    ONLINE_FILE="/sys/class/power_supply/AC/online"
elif [ -f /sys/class/power_supply/Mains/online ]; then
    ONLINE_FILE="/sys/class/power_supply/Mains/online"
else
    # Si aucun fichier online trouvé, on cherche un BAT* et on suppose status
    ONLINE_FILE=""
fi

if [ -n "$ONLINE_FILE" ] && [ -f "$ONLINE_FILE" ]; then
    ONLINE=$(cat "$ONLINE_FILE" 2>/dev/null || echo "0")
else
    # Alternative : on regarde si le système est en "Discharging"
    if [ -f /sys/class/power_supply/BAT0/status ]; then
        STATUS=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "Unknown")
    elif [ -f /sys/class/power_supply/BAT1/status ]; then
        STATUS=$(cat /sys/class/power_supply/BAT1/status 2>/dev/null || echo "Unknown")
    else
        STATUS="Unknown"
    fi

    if [ "$STATUS" = "Discharging" ]; then
        ONLINE=0
    else
        ONLINE=1
    fi
fi

# Choisir la fréquence
if [ "$ONLINE" = "1" ]; then
    HZ=$HZ_ON_AC
else
    HZ=$HZ_ON_BATTERY
fi

# Appliquer avec cosmic-randr
cosmic-randr mode --refresh "$HZ" "$OUTPUT" "$WIDTH" "$HEIGHT"
SCRIPT_EOF

chmod +x "$SCRIPT_PATH"
echo "  ✓ Script créé et exécutable"

# 2. Créer la règle udev
echo "[2/3] Création de la règle udev $RULE_PATH"

cat > "$RULE_PATH" << 'RULE_EOF'
ACTION=="change", SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="/usr/local/bin/power-refresh-cosmic.sh"
ACTION=="change", SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="/usr/local/bin/power-refresh-cosmic.sh"

# Si ton système utilise AC au lieu de Mains, ajoute ces lignes (décommente si besoin) :
# ACTION=="change", SUBSYSTEM=="power_supply", ATTR{type}=="AC", ATTR{online}=="0", RUN+="/usr/local/bin/power-refresh-cosmic.sh"
# ACTION=="change", SUBSYSTEM=="power_supply", ATTR{type}=="AC", ATTR{online}=="1", RUN+="/usr/local/bin/power-refresh-cosmic.sh"
RULE_EOF

echo "  ✓ Règle udev créée"

# 3. Recharger udev
echo "[3/3] Rechargement des règles udev"
udevadm control --reload-rules
echo "  ✓ Règles rechargées"

echo ""
echo "=== Installation terminée ==="
echo ""
echo "Test manuel du script :"
echo "  /usr/local/bin/power-refresh-cosmic.sh"
echo ""
echo "Pour vérifier l'état de l'alimentation :"
echo "  cat /sys/class/power_supply/AC/online        (1 = branché, 0 = débranché)"
echo "  ou"
echo "  cat /sys/class/power_supply/Mains/online"
echo ""
echo "Si ton système utilise 'AC' au lieu de 'Mains', ouvre :"
echo "  $RULE_PATH"
echo "et décommente les lignes pour ATTR{type}='AC'."
echo ""
echo "Dernier point : si le script ne s'exécute pas automatiquement, reboot COSMIC (quitte COSMIC et reconnecte-toi), ou reboot complet."
echo ""
echo "=== Fin de l'installation ==="
