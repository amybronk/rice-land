#!/bin/bash

# detecteer package manager
if command -v pacman &>/dev/null; then
    sudo pacman -S --needed --noconfirm \
        hyprland \
        qt5-graphicaleffects \
        qt6-declarative \
        git \
        libnotify \
        vivaldi \
        kate \
        rofi \
        awww
    
    yay -S --noconfirm --rebuild --needed \
        quickshell \
        matugen-bin 

    echo "✓ Packages geïnstalleerd via pacman and the aur"
else
    echo "✗ Geen ondersteunde package manager gevonden (alleen pacman ondersteund)"
    exit 1
fi