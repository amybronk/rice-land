#!/bin/bash

BLUE="\033[34m"
BOLD="\033[1m"
RESET="\033[0m"

echo -e "${BOLD}${BLUE}>>> Installeren van Flatpaks: Bitwarden, GearLever, Obsidian, Heroic, ProtonPlus, Flatseal...${RESET}"

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install --noninteractive \
    com.bitwarden.desktop \
    it.mijorus.gearlever \
    md.obsidian.Obsidian \
    com.heroicgameslauncher.hgl \
    com.vysp3r.ProtonPlus \
    com.github.tchx84.Flatseal \
    io.appflowy.AppFlowy \
    flatpak run app.eduroam.geteduroam