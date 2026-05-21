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
        rofi
    
    yay -S --noconfirm \
        quickshell \
        matugen-bin

    mkdir -p ~/.config/matugen/templates

    echo "✓ Packages geïnstalleerd via pacman and the aur"
else
    echo "✗ Geen ondersteunde package manager gevonden (alleen pacman ondersteund)"
    exit 1
fi