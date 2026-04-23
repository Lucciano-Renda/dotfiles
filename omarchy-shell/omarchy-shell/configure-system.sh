#!/bin/bash
# configure-system.sh
# Configures Hyprland, Shell, and GRUB theme

set -e  # Exit on error

echo "========================================="
echo "  CONFIGURING SYSTEM"
echo "========================================="

# --- HYPRLAND CONFIGURATION ---
echo "Configuring Hyprland settings..."
HYPR_CONF="$HOME/.config/hypr/hyprland.conf"
mkdir -p "$(dirname "$HYPR_CONF")"

cat <<EOF >> "$HYPR_CONF"

# === Custom Configuration Added by Setup Script ===

source = ~/Omrchy-shell/hprpersonal.conf

EOF

echo ""
