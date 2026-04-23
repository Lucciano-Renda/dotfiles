#!/bin/bash

# TP-Link TX20UH Driver Installation Script for Arch Linux
# This script installs the rtw89 driver for TP-Link TX20UH WiFi adapter
# Handles Windows dual-boot issues and kernel updates

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}TP-Link TX20UH Driver Installer${NC}"
echo -e "${GREEN}(Windows Dual-Boot Compatible)${NC}"
echo -e "${GREEN}================================${NC}\n"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}Error: Do not run this script as root. It will ask for sudo when needed.${NC}"
   exit 1
fi

# Detect current kernel version
KERNEL_VERSION=$(uname -r)
echo -e "${BLUE}Current kernel: ${KERNEL_VERSION}${NC}\n"

# Step 1: Install dependencies
echo -e "${YELLOW}[1/12]${NC} Installing dependencies..."
sudo pacman -S --needed --noconfirm base-devel linux-headers git dkms bc usbutils networkmanager

# Step 2: Clean old installations
echo -e "${YELLOW}[2/12]${NC} Cleaning old driver installations..."
sudo dkms remove rtw89/6.19 --all 2>/dev/null || true
sudo rm -rf /lib/modules/*/extra/rtw89/ 2>/dev/null || true
sudo rm -rf /usr/src/rtw89-* 2>/dev/null || true

# Step 3: Download rtw89 driver
echo -e "${YELLOW}[3/12]${NC} Downloading rtw89 driver..."
cd ~
if [ -d "rtw89" ]; then
    echo "Removing old rtw89 directory..."
    rm -rf rtw89
fi
git clone https://github.com/morrownr/rtw89.git
cd rtw89

# Step 4: Install with DKMS (auto-recompiles on kernel updates)
echo -e "${YELLOW}[4/12]${NC} Installing driver with DKMS..."
sudo mkdir -p /usr/src/rtw89-6.19
sudo cp -r ~/rtw89/* /usr/src/rtw89-6.19/
sudo dkms add -m rtw89 -v 6.19
sudo dkms build -m rtw89 -v 6.19
sudo dkms install -m rtw89 -v 6.19

# Step 5: Copy USB storage configuration
echo -e "${YELLOW}[5/12]${NC} Configuring USB storage..."
sudo cp ~/rtw89/usb_storage.conf /etc/modprobe.d/

# Step 6: Configure firmware (copy if exists)
echo -e "${YELLOW}[6/12]${NC} Installing firmware..."
if [ -d ~/rtw89/firmware ]; then
    sudo mkdir -p /lib/firmware/rtw89
    sudo cp -r ~/rtw89/firmware/* /lib/firmware/rtw89/ 2>/dev/null || true
fi

# Step 7: Update kernel modules
echo -e "${YELLOW}[7/12]${NC} Updating kernel modules..."
sudo depmod -a

# Step 8: Configure automatic module loading
echo -e "${YELLOW}[8/12]${NC} Configuring automatic module loading..."
cat << 'EOF' | sudo tee /etc/modules-load.d/rtw89.conf > /dev/null
rtw89_core_git
rtw89_usb_git
rtw89_8852a_git
EOF

# Step 9: Configure module parameters for stability
echo -e "${YELLOW}[9/12]${NC} Configuring driver parameters..."
cat << 'EOF' | sudo tee /etc/modprobe.d/rtw89.conf > /dev/null
# RTW89 driver configuration for stability
options rtw89_core disable_ps_mode=Y
options rtw89_pci disable_aspm=Y
options rtw89_core disable_clkreq=Y
options rtw89_core disable_msi=N
# Disable power saving features that cause disconnections
options rtw89_8852a_git disable_ps_mode=1
options rtw89_usb_git disable_ps_mode=1
softdep rtw89_usb_git pre: rtw89_core_git
softdep rtw89_8852a_git pre: rtw89_core_git
softdep rtw89_8852au_git pre: rtw89_core_git rtw89_usb_git rtw89_8852a_git
EOF

# Step 9b: Fix USB power issues (prevents error -71 and random disconnections)
echo -e "${YELLOW}[9b/12]${NC} Fixing USB power management (prevents disconnections)..."
cat << 'EOF' | sudo tee /etc/modprobe.d/usb-power.conf > /dev/null
# Disable USB autosuspend to prevent WiFi adapter disconnections
options usbcore autosuspend=-1
options usbcore initial_descriptor_timeout=5000
# Increase USB timeout values for stability
options usbcore old_scheme_first=1
EOF

# Step 9c: Configure NetworkManager for stable WiFi
echo -e "${YELLOW}[9c/12]${NC} Configuring NetworkManager for WiFi stability..."
sudo mkdir -p /etc/NetworkManager/conf.d/
cat << 'EOF' | sudo tee /etc/NetworkManager/conf.d/wifi-stability.conf > /dev/null
[device]
# Disable WiFi power saving
wifi.powersave=2

[connection]
# Increase connection timeout
ipv4.dhcp-timeout=30
ipv6.dhcp-timeout=30

# Disable WiFi scanning while connected
wifi.scan-rand-mac-address=no
EOF

# Step 10: Configure USB mode switching with multiple methods
echo -e "${YELLOW}[10/12]${NC} Configuring USB mode switching (dual-boot fix)..."
cat << 'EOF' | sudo tee /etc/udev/rules.d/40-usb_modeswitch.rules > /dev/null
# TP-Link TX20UH - RTL8188GU mode switch
ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="1a2b", RUN+="/usr/bin/usb_modeswitch -K -W -v 0bda -p 1a2b"

# TP-Link TX20UH - RTL8852AU direct recognition
ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="2357", ATTRS{idProduct}=="0141", RUN+="/bin/sh -c 'sleep 2; modprobe rtw89_8852au_git'"
EOF

# Step 11: Create systemd service for post-boot WiFi fix
echo -e "${YELLOW}[11/12]${NC} Creating recovery service for Windows dual-boot..."
cat << 'EOF' | sudo tee /etc/systemd/system/tplink-wifi-fix.service > /dev/null
[Unit]
Description=TP-Link WiFi Adapter Recovery Service
After=network.target NetworkManager.service

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'sleep 5; if ! ip link show | grep -q wlan; then modprobe -r rtw89_8852au_git rtw89_8852a_git rtw89_usb_git rtw89_core_git 2>/dev/null; sleep 2; modprobe rtw89_core_git; modprobe rtw89_usb_git; modprobe rtw89_8852a_git; fi; sleep 2; for iface in $(ls /sys/class/net/ | grep wlan); do iw dev $iface set power_save off 2>/dev/null || true; done'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable tplink-wifi-fix.service

# Step 11b: Create script to disable WiFi power saving on connect
echo -e "${YELLOW}[11b/12]${NC} Creating WiFi connection stability script..."
cat << 'EOF' | sudo tee /etc/NetworkManager/dispatcher.d/99-wifi-powersave-off > /dev/null
#!/bin/bash
# Disable WiFi power saving when connecting to prevent disconnections

if [ "$2" = "up" ] && [ "$1" != "lo" ]; then
    if [[ "$1" == wlan* ]]; then
        # Disable power saving
        iw dev "$1" set power_save off 2>/dev/null || true
        # Set low latency mode
        iw dev "$1" set txpower fixed 3000 2>/dev/null || true
        logger "WiFi power saving disabled for $1 (stability fix)"
    fi
fi
EOF

sudo chmod +x /etc/NetworkManager/dispatcher.d/99-wifi-powersave-off

# Step 12: Reload udev rules
echo -e "${YELLOW}[12/12]${NC} Reloading udev rules..."
sudo udevadm control --reload-rules

# Step 13: Regenerate initramfs for all kernels
echo -e "${YELLOW}[13/13]${NC} Regenerating initramfs..."
sudo mkinitcpio -P

echo -e "\n${GREEN}================================${NC}"
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "${GREEN}================================${NC}\n"

echo -e "${BLUE}What was fixed:${NC}"
echo "✓ DKMS support - driver recompiles automatically on kernel updates"
echo "✓ Dual-boot compatibility - WiFi recovers after Windows boot"
echo "✓ USB mode switching - handles both CDROM and WiFi modes"
echo "✓ Recovery service - auto-fixes driver after problematic boots"
echo "✓ Firmware installation - complete driver support"
echo "✓ USB power management - prevents error -71 disconnections"
echo "✓ WiFi power saving disabled - prevents random disconnections"
echo "✓ NetworkManager optimized - stable connection handling"
echo "✓ Connection stability script - maintains connection quality"

echo -e "\n${YELLOW}Next steps:${NC}"
echo "1. Reboot your system: ${GREEN}sudo reboot${NC}"
echo "2. After reboot, verify adapter: ${GREEN}lsusb | grep TP-Link${NC}"
echo "3. Check WiFi interface: ${GREEN}ip link | grep wlan${NC}"
echo "4. List networks: ${GREEN}nmcli device wifi list${NC}"
echo "5. Connect to WiFi: ${GREEN}nmcli device wifi connect \"SSID\" password \"PASSWORD\"${NC}"

echo -e "\n${BLUE}Connection stability commands (if still experiencing issues):${NC}"
echo "• Check power save status: ${GREEN}iw dev wlan1 get power_save${NC}"
echo "• Manually disable power save: ${GREEN}sudo iw dev wlan1 set power_save off${NC}"
echo "• Monitor connection: ${GREEN}watch -n1 'iw dev wlan1 link'${NC}"
echo "• Check signal strength: ${GREEN}watch -n1 'nmcli dev wifi list'${NC}"

echo -e "\n${BLUE}Troubleshooting (if WiFi doesn't work after reboot):${NC}"
echo "• Manually reload driver: ${GREEN}sudo systemctl restart tplink-wifi-fix${NC}"
echo "• Check driver status: ${GREEN}dkms status${NC}"
echo "• View logs: ${GREEN}sudo journalctl -u tplink-wifi-fix${NC}"
echo "• Check for errors: ${GREEN}sudo dmesg | grep -i rtw89${NC}"

echo -e "\n${YELLOW}Do you want to reboot now? (y/n)${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "${GREEN}Rebooting...${NC}"
    sudo reboot
else
    echo -e "${YELLOW}Please reboot manually when ready.${NC}"
    echo -e "${BLUE}To manually test stability improvements without rebooting:${NC}"
    echo "sudo systemctl restart NetworkManager"
    echo "sudo iw dev wlan1 set power_save off"
    echo "nmcli device wifi list"
fi
