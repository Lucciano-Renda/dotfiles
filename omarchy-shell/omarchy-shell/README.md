# Omarchy System Setup

Automated setup scripts for configuring Arch Linux with Hyprland, TP-Link WiFi adapter, and custom theming.

## 📋 What This Does

This setup automates:
- **Package Installation**: Base development tools, Firefox, Zsh, Starship, and more
- **WiFi Driver**: TP-Link rtl8188gu driver installation and configuration
- **Hyprland Config**: Custom keybinds, input settings, and window rules
- **Shell Theme**: Starship prompt with plain-text symbols preset
- **GRUB Theme**: Minegrub World Selection theme

## 📁 Project Structure

```
.
├── setup.sh              # Main orchestrator script
├── install-packages.sh   # Installs system packages
├── install-tplink.sh     # Configures TP-Link WiFi adapter
├── configure-system.sh   # Sets up Hyprland, shell, and GRUB
└── README.md            # This file
```

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
cd YOUR_REPO_NAME
```

### 2. Make Scripts Executable

```bash
chmod +x setup.sh install-packages.sh install-tplink.sh configure-system.sh
```

### 3. Run the Main Setup Script

```bash
./setup.sh
```

The script will:
1. Ask for confirmation before proceeding
2. Install all required packages
3. Configure the TP-Link WiFi adapter
4. Set up Hyprland, shell, and GRUB theme

### 4. Restart Your System

```bash
sudo reboot
```

## 🔧 Running Individual Scripts

If you only need specific functionality:

### Install Packages Only
```bash
./install-packages.sh
```

### Install WiFi Driver Only
```bash
./install-tplink.sh
```

### Configure System Only
```bash
./configure-system.sh
```

## 📝 What Gets Configured

### Hyprland Settings
- **Keyboard Layout**: Latin American (latam)
- **Caps Lock**: Remapped to Compose key
- **Touchpad**: Two-finger click behavior enabled
- **Window Gaps**: Minimal gaps (2px in, 4px out)
- **Rounding**: 8px rounded corners

### Keybinds
- `SUPER + B`: Opens Firefox

### Shell
- **Zsh**: Default shell with Starship prompt
- **Starship**: Plain-text symbols preset

### GRUB
- **Theme**: Minegrub World Selection (Minecraft-style boot menu)

## ⚠️ Requirements

- **OS**: Arch Linux (or Arch-based distro)
- **Display Server**: Hyprland
- **Permissions**: sudo access required
- **Internet**: Required for downloading packages and repositories

## 🛠️ Troubleshooting

### WiFi Adapter Not Working
```bash
# Check if driver loaded
lsmod | grep 8188gu

# Reload driver
sudo modprobe -r 8188gu
sudo modprobe 8188gu
```

### GRUB Theme Not Showing
```bash
# Regenerate GRUB config
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

### Starship Not Loading
```bash
# Ensure Starship is initialized in .zshrc
grep "starship init zsh" ~/.zshrc

# Manually add if missing
echo 'eval "$(starship init zsh)"' >> ~/.zshrc
```

## 🤝 Contributing

Feel free to submit issues or pull requests if you have improvements!

## 📄 License

This project is provided as-is for personal use.

---

**Note**: Always review scripts before running them with sudo privileges. These scripts modify system files and configurations.
