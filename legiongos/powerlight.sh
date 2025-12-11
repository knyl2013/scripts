#!/bin/bash

# Prerequisite (Make sure to install these packages first):
# Decky Loader: https://github.com/SteamDeckHomebrew/decky-loader
# LegionGoRemapper: https://github.com/aarron-lee/LegionGoRemapper

# --- CONFIGURATION ---
# If the script fails in the future, update these variables with the info from:
# https://steamdeck-packages.steamos.cloud/archlinux-mirror/jupiter-main/os/x86_64/
KERNEL_VERSION="6.11.11.valve24-1"
HEADER_PKG_NAME="linux-neptune-611-headers"
HEADER_FULL_NAME="${HEADER_PKG_NAME}-${KERNEL_VERSION}-x86_64.pkg.tar.zst"
HEADER_URL="https://steamdeck-packages.steamos.cloud/archlinux-mirror/jupiter-main/os/x86_64/${HEADER_FULL_NAME}"

# --- SETUP ---
set -e # Exit immediately if a command fails

cleanup() {
    echo ":: Cleaning up..."
    rm -f "$HEADER_FULL_NAME"
    echo ":: Re-enabling SteamOS read-only mode..."
    steamos-readonly enable
}
trap cleanup EXIT

echo ":: Disabling SteamOS read-only mode..."
steamos-readonly disable

echo ":: Installing acpi_call-dkms..."
pacman -S --needed --noconfirm acpi_call-dkms
curl -O "$HEADER_URL"
pacman -U "$HEADER_FULL_NAME"
pacman -S acpi_call-dkms

echo ":: SUCCESS! The system will now reboot."
echo ":: Press Ctrl+C within 5 seconds to cancel reboot."
sleep 5
reboot
