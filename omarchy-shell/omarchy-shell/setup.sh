#!/bin/bash
# setup.sh
# Main setup script that orchestrates all installation steps

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================="
echo "  OMARCHY SYSTEM SETUP"
echo "========================================="
echo "This script will:"
echo "  1. Install required packages"
echo "  2. Unninstall my unwanted"
echo "  3. Configure TP-Link WiFi adapter"
echo "  4. Configure Hyprland, Shell, and GRUB"
echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..."
echo ""

# Function to run scripts safely
run_step() {
    local script_path="$SCRIPT_DIR/$1"
    local description=$2

    if [ -f "$script_path" ]; then
        echo "------------------------------------------"
        echo "STEP: $description"
        echo "------------------------------------------"
        # Using 'bash' means we don't need chmod +x
        bash "$script_path"
    else
        echo "ERROR: $1 not found!"
        exit 1
    fi
}

# Now your "Chain" is much cleaner:
run_step "install-packages.sh" "Installing Yay, VSCodium, and OnlyOffice"
run_step "uninstall-apps.sh"   "Removing Bloatware"
run_step "install-tplink.sh"   "Setting up TX20UH Drivers"
run_step "configure-system.sh" "Applying Hyprland Dotfiles"

echo "========================================="
echo "  ✓ SETUP COMPLETE!"
echo "========================================="
echo ""
echo "Next steps:"
echo "  1. Restart your system to apply WiFi drivers"
echo "  2. See the new GRUB menu on boot"
echo "  3. Log out and back in to activate Zsh/Starship"
echo ""
echo "Enjoy your configured system!"
echo ""
