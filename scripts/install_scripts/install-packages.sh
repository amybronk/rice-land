#!/bin/bash

RESET="\033[0m"
BOLD="\033[1m"
GREEN="\033[32m"
ORANGE="\033[33m"
RED="\033[31m"

SUCCESS="${BOLD}${GREEN}"
WARNING="${BOLD}${ORANGE}"
ERROR="${BOLD}${RED}"

# detecteer package manager
if command -v pacman &>/dev/null; then
    sudo pacman -S --needed --noconfirm \
        libnotify \
        libjxl \
        hyprland \
        qt5-graphicaleffects \
        qt6-declarative \
        git \
        vivaldi \
        kate \
        rofi \
        awww \
        alacritty \
        fastfetch \
        fish \
        starship \
        eza \
        bat \
        ugrep \
        reflector \
        expac \
        hwinfo \
        meld \
        micro
    
    yay -S --noconfirm --rebuild --needed \
        quickshell \
        matugen-bin 

    echo "${SUCCESS}✓ Packages geïnstalleerd via pacman and the aur${RESET}"
else
    echo "${ERROR}✗ Geen ondersteunde package manager gevonden (alleen pacman ondersteund)${RESET}"
    exit 1
fi