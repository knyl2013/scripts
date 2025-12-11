#!/bin/bash

# powerlight.sh

# --- CONFIGURATION ---
# If the script fails in the future, update these variables with the info from:
# https://steamdeck-packages.steamos.cloud/archlinux-mirror/jupiter-main/os/x86_64/
KERNEL_VERSION="6.11.11.valve24-1"
HEADER_PKG_NAME="linux-neptune-611-headers"
HEADER_FULL_NAME="${HEADER_PKG_NAME}-${KERNEL_VERSION}-x86_64.pkg.tar.zst"
HEADER_URL="https://steamdeck-packages.steamos.cloud/archlinux-mirror/jupiter-main/os/x86_64/${HEADER_FULL_NAME}"

# --- SETUP ---
set -e # Exit immediately if a command fails

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  echo "Usage: sudo ./powerlight.sh"
  exit 1
fi

cleanup() {
    echo ":: Cleaning up..."
    rm -f "$HEADER_FULL_NAME"
    echo ":: Re-enabling SteamOS read-only mode..."
    steamos-readonly enable
}
trap cleanup EXIT

echo ":: Disabling SteamOS read-only mode..."
steamos-readonly disable

echo ":: Initializing Pacman keys (fixes common download errors)..."
pacman-key --init
pacman-key --populate archlinux jupiter holo
pacman -Sy

echo ":: Installing build dependencies..."
pacman -S --needed --noconfirm base-devel

echo ":: Handling Kernel Headers..."
if pacman -S --noconfirm "$HEADER_PKG_NAME"; then
    echo ":: Headers installed successfully via Pacman repositories."
else
    echo ":: Header package not found in current repo sync. Attempting manual download..."
    echo ":: Downloading: $HEADER_FULL_NAME"
    
    if curl -O "$HEADER_URL"; then
        echo ":: Installing manually downloaded headers..."
        pacman -U --noconfirm "$HEADER_FULL_NAME"
    else
        echo "Error: Could not download headers. Please check the version URL manually."
        exit 1
    fi
fi

echo ":: Installing acpi_call-dkms..."
pacman -S --needed --noconfirm acpi_call-dkms

echo ":: Loading module..."
modprobe acpi_call || echo ":: Module loaded or will load on reboot."

echo ":: SUCCESS! The system will now reboot."
echo ":: Press Ctrl+C within 5 seconds to cancel reboot."
sleep 5
reboot
