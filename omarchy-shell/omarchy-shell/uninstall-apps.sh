#!/bin/bash
# uninstall-apps.sh
# Removes Typora and Signal from the system

set -e  # Exit on error

echo "========================================="
echo "  UNINSTALLING APPLICATIONS"
echo "========================================="

# --- Remove Specific Apps ---
apps_to_remove=("typora" "signal-desktop")

for app in "${apps_to_remove[@]}"; do
    if pacman -Qi "$app" &> /dev/null; then
        echo "Removing $app..."
        sudo pacman -Rns "$app" --noconfirm
        echo "✓ $app removed"
    else
        echo "⊘ $app is not installed"
    fi
done

# --- Clean up orphaned dependencies ---
# We store the list in a variable first to check if it's empty
ORPHANS=$(pacman -Qtdq)

echo -e "\nCleaning up orphaned packages..."
if [ -n "$ORPHANS" ]; then
    echo "$ORPHANS" | sudo pacman -Rns - --noconfirm
else
    echo "No orphaned packages to remove."
fi

# --- Clean package cache ---
echo "Cleaning package cache..."
sudo pacman -Sc --noconfirm

echo ""
echo "========================================="
echo "  ✓ UNINSTALLATION COMPLETE"
echo "========================================="
echo ""
