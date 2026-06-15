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
        git \
        hyprland \
        hyprshot \
        hyprpicker \
        quickshell \
        rofi \
        fish \
        kate \
        alacritty \
        fastfetch \
        wl-clipboard \
        wl-clip-persist \
        cliphist \
        playerctl \
        unzip \
        btop \
        hwinfo \
        starship \
        tumbler \
        micro \
        eza \
        bat \
        ugrep \
        reflector \
        expac \
        meld \
        pavucontrol \
        brightnessctl \
        libnotify \
        libjxl \
        qt5-graphicaleffects \
        qt6-declarative \
        breeze-icons \
        kdeconnect \
        drawy \
        satty \
        pulseview \
        prusa-slicer \
        kicad \
        freecad \
        libreoffice-still \
        discord \
        spotify-launcher

    
    yay -S --noconfirm --rebuild --needed \
        matugen-bin \
        qt6ct-kde \
        qt5ct-kde \
        vscodium-bin \
        whatpulse \
        vivaldi \
        awww \
        whatpulse-external-pcap \
        nwg-look

    echo "${SUCCESS}✓ Packages geïnstalleerd via pacman and the aur${RESET}"
else
    echo "${ERROR}✗ Geen ondersteunde package manager gevonden (alleen pacman ondersteund)${RESET}"
    exit 1
fi
