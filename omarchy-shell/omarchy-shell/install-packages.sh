#!/bin/bash
# install-packages.sh
# Installs all required system packages and applications

set -e  # Exit on error

echo "========================================="
echo "  INSTALLING SYSTEM PACKAGES"
echo "========================================="

echo "Updating system and installing base dependencies..."
sudo pacman -Syu --needed \
    firefox \
    yazi \
    stow \
    usb_modeswitch
    
if ! command -v yay &> /dev/null; then
    echo "yay not found. Installing yay..."

    # Install base-devel and git if they aren't present
    sudo pacman -S --needed --noconfirm base-devel git

    # Create a temporary directory for the build
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"

    # Clone and build yay
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm

    # Clean up
    cd ~
    rm -rf "$TEMP_DIR"
    echo "yay installed successfully."
else
    echo "yay is already installed. Skipping installation."
fi

# 2. Update system and install packages
echo "Installing YAY list"

# Using --answerdiff None and --answeredit None to make it fully automatic
yay -S --noconfirm --answerdiff None --answeredit None \
    vscodium \
    bazaar

echo "✓ Package installation complete"

# Set Default Browser
echo "Setting Firefox as default browser..."
xdg-settings set default-web-browser firefox.desktop

echo "✓ Default browser configured"
echo ""
