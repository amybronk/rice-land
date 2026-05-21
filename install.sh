#!/bin/bash

# ═══════════════════════════════════════════════════════════════
#  QuickShell installatie & update script
#  Gebruik: bash install.sh
#  repo: https://github.com/amybronk/rice-land.git
#
#  Dit script is veilig om meerdere keren te draaien.
#  Het installeert bij de eerste keer, en update bij volgende keren.
# ═══════════════════════════════════════════════════════════════

set -e  # stop bij een fout

REPO_URL="https://github.com/amybronk/rice-land.git"

CONFIG_DIR="$HOME/.config"
QS_CONFIG_DIR="$CONFIG_DIR/quickshell"

# Vaste locatie waar de repo naartoe wordt gecloned
REPO_DIR="$HOME/.local/share/quickshell-dotfiles"

# Lijst met mappen die je wilt linken naar ~/.config
FOLDERS=("quickshell" "hypr" "rofi" "matugen")

# Wallpaper mappen
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
PICTURES_DIR="$HOME/Pictures"
DEFAULT_PICTURES_DIR="$REPO_DIR/default pictures"

# ── ANSI Kleuren en Stijlen ────────────────────────────────────
RESET="\033[0m"
BOLD="\033[1m"
GREEN="\033[32m"
ORANGE="\033[33m"
RED="\033[31m"

SUCCESS="${BOLD}${GREEN}"
WARNING="${BOLD}${ORANGE}"
ERROR="${BOLD}${RED}"

# ── detecteer of dit een eerste installatie of een update is ────

IS_UPDATE=false
if [ -d "$REPO_DIR/.git" ]; then
    IS_UPDATE=true
fi

echo -e ""
echo -e "╔══════════════════════════════════════╗"
if $IS_UPDATE; then
echo -e "║   QuickShell update                  ║"
else
echo -e "║   QuickShell installatie             ║"
fi
echo -e "╚══════════════════════════════════════╝"
echo -e ""

# ── 1. package manager controleren ──────────────────────────────

if ! command -v pacman &>/dev/null; then
    echo -e "${ERROR}✗ Geen ondersteunde package manager gevonden (alleen pacman ondersteund)${RESET}"
    exit 1
fi

# ── 2. git installeren ───────────────────────────────────────────

echo -e ">>> Git installeren (indien nodig)..."

if ! command -v git &>/dev/null; then
    sudo pacman -S --needed --noconfirm git
    echo -e "${SUCCESS}✓ git geïnstalleerd${RESET}"
else
    echo -e "${SUCCESS}✓ git is al geïnstalleerd${RESET}"
fi

# ── 3. yay installeren ───────────────────────────────────────────

echo -e ""
echo -e ">>> Yay (AUR helper) installeren (indien nodig)..."

if ! command -v yay &>/dev/null; then
    if ! pacman -Qq base-devel &>/dev/null 2>&1; then
        echo -e "  base-devel installeren..."
        sudo pacman -S --needed --noconfirm base-devel
    fi

    YAY_BUILD_DIR="/tmp/yay-build"
    rm -rf "$YAY_BUILD_DIR"
    git clone https://aur.archlinux.org/yay.git "$YAY_BUILD_DIR"

    ( cd "$YAY_BUILD_DIR" && makepkg -si --noconfirm )

    rm -rf "$YAY_BUILD_DIR"
    echo -e "${SUCCESS}✓ yay geïnstalleerd${RESET}"
else
    echo -e "${SUCCESS}✓ yay is al geïnstalleerd${RESET}"
fi

# ── 4. repo clonen of updaten ────────────────────────────────────

echo -e ""
echo -e ">>> Repo ophalen..."

if [ -d "$REPO_DIR/.git" ]; then
    echo -e "  Repo updaten..."
    git -C "$REPO_DIR" pull
    echo -e "${SUCCESS}✓ Repo geüpdated${RESET}"
else
    mkdir -p "$(dirname "$REPO_DIR")"
    git clone "$REPO_URL" "$REPO_DIR"
    echo -e "${SUCCESS}✓ Repo gecloned naar $REPO_DIR${RESET}"
fi

# ── 5. config mappen linken ──────────────────────────────────────

echo -e ""
echo -e ">>> Dotfiles koppelen..."

for folder in "${FOLDERS[@]}"; do
    if [ -d "$REPO_DIR/$folder" ]; then

        mkdir -p "$CONFIG_DIR"

        if [ -d "$CONFIG_DIR/$folder" ] && [ ! -L "$CONFIG_DIR/$folder" ]; then
            BACKUP="$CONFIG_DIR/${folder}_backup_$(date +%Y%m%d_%H%M%S)"
            echo -e "  Backup gemaakt: $CONFIG_DIR/$folder → $BACKUP"
            mv "$CONFIG_DIR/$folder" "$BACKUP"
        fi

        ln -sf "$REPO_DIR/$folder" "$CONFIG_DIR/$folder"
        echo -e "  ${SUCCESS}✓ Gekoppeld: $folder → $CONFIG_DIR/$folder${RESET}"
    else
        echo -e "  ${WARNING}⚠ Map '$folder' niet gevonden in repo, overgeslagen${RESET}"
    fi
done

echo -e "${SUCCESS}✓ Dotfiles gekoppeld${RESET}"

# ── 6. scripts uitvoerbaar maken ─────────────────────────────────

echo -e ""
echo -e ">>> Scripts uitvoerbaar maken..."

find "$REPO_DIR" -name "*.sh" -exec chmod +x {} +
echo -e "${SUCCESS}✓ Alle .sh bestanden in de repo uitvoerbaar gemaakt${RESET}"

# ── 7. sudoers regel voor shutdown ───────────────────────────────

echo -e ""
echo -e ">>> Sudoers instellen voor shutdown..."

SUDOERS_BESTAND="/etc/sudoers.d/quickshell-shutdown"

if [ ! -f "$SUDOERS_BESTAND" ]; then
    echo "$USER ALL=(ALL) NOPASSWD: /usr/sbin/shutdown" \
        | sudo tee "$SUDOERS_BESTAND" > /dev/null
    sudo chmod 440 "$SUDOERS_BESTAND"
    echo -e "${SUCCESS}✓ Sudoers regel toegevoegd${RESET}"
else
    echo -e "${SUCCESS}✓ Sudoers regel bestaat al${RESET}"
fi

# ── 8. wallpaper map aanmaken (alleen bij eerste installatie) ────

if ! $IS_UPDATE; then
    echo -e ""
    echo -e ">>> Wallpaper map aanmaken..."

    if [ ! -d "$WALLPAPER_DIR" ]; then
        mkdir -p "$WALLPAPER_DIR"

        mkdir -p "$PICTURES_DIR"
        COPIED=$(find "$DEFAULT_PICTURES_DIR" -maxdepth 1 -type f \
            \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \
               -o -iname "*.webp" -o -iname "*.gif" -o -iname "*.bmp" \
               -o -iname "*.tiff" -o -iname "*.qoi" -o -iname "*.ico" \) \
            -exec cp {} "$WALLPAPER_DIR/" \; -print | wc -l)

        if [ "$COPIED" -gt 0 ]; then
            echo -e "  ${SUCCESS}✓ $COPIED foto('s) gekopieerd naar $WALLPAPER_DIR${RESET}"
        else
            echo -e "  ${WARNING}⚠ Geen afbeeldingen gevonden in $DEFAULT_PICTURES_DIR${RESET}"
            echo -e "    Voeg zelf wallpapers toe aan: $WALLPAPER_DIR"
        fi

        echo -e "${SUCCESS}✓ Wallpaper map aangemaakt: $WALLPAPER_DIR${RESET}"
    else
        echo -e "${SUCCESS}✓ Wallpaper map bestaat al, overgeslagen${RESET}"
    fi
fi

# ── 9. systeem updaten & Qt-versie bijhouden ─────────────────────

echo -e ""
echo -e ">>> Systeem updaten..."

QT_VERSION_VOOR=$(pacman -Q qt6-base 2>/dev/null | awk '{print $2}' | cut -d. -f1,2 || echo "niet-geinstalleerd")

sudo pacman -Syu --noconfirm
echo -e "${SUCCESS}✓ Systeem geüpdated via pacman${RESET}"

yay -Syu --noconfirm --ignore quickshell
echo -e "${SUCCESS}✓ AUR pakketten geüpdated via yay${RESET}"

QT_VERSION_NA=$(pacman -Q qt6-base 2>/dev/null | awk '{print $2}' | cut -d. -f1,2 || echo "niet-geinstalleerd")

echo -e ""
echo -e "  Qt versie vóór update : $QT_VERSION_VOOR"
echo -e "  Qt versie na update   : $QT_VERSION_NA"

# ── 10. packages installeren / quickshell hercompileren ───────────

echo -e ""
echo -e ">>> Packages controleren..."

INSTALL_SCRIPT="$REPO_DIR/scripts/install_scripts/install-packages.sh"

if [ -f "$INSTALL_SCRIPT" ]; then
    chmod +x "$INSTALL_SCRIPT"
    bash "$INSTALL_SCRIPT"
else
    echo -e "  ${WARNING}⚠ install-packages.sh niet gevonden op: $INSTALL_SCRIPT${RESET}"
    echo -e "  Handmatig overgeslagen."
fi

if [ "$QT_VERSION_VOOR" != "$QT_VERSION_NA" ]; then
    echo -e ""
    echo -e ">>> Qt versie gewijzigd ($QT_VERSION_VOOR → $QT_VERSION_NA)"
    echo -e "    QuickShell hercompileren tegen nieuwe Qt..."
    yay -S --noconfirm --rebuild quickshell
    echo -e "${SUCCESS}✓ QuickShell hergecompileerd${RESET}"
else
    yay -S --noconfirm quickshell
    echo -e "${SUCCESS}✓ QuickShell is up-to-date${RESET}"
fi

# ── 11. hyprland herladen & awww starten ───────────────────

echo -e ""
echo -e ">>> Hyprland herladen & awww starten"

if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ] && command -v hyprctl &>/dev/null; then
    awww-daemon &
    sleep 0.2

    sh "$REPO_DIR/scripts/backgroundSwicher/change_wallpaper.sh" "$WALLPAPER_DIR/pincones.jpg"
    echo -e "${SUCCESS}✓ Wallpaper ingesteld${RESET}"

    hyprctl reload
    echo -e "${SUCCESS}✓ Hyprland config herladen${RESET}"
else
    echo -e "  ${WARNING}⚠ Hyprland draait niet, reload overgeslagen${RESET}"
    echo -e "    Start Hyprland opnieuw om de nieuwe config te laden"
fi

# ── 12. init systeem detecteren ──────────────────────────────────

echo -e ""
echo -e ">>> Init systeem detecteren..."

if [ "$(cat /proc/1/comm)" = "systemd" ]; then
    INIT="systemd"
elif [ -f /run/openrc/softlevel ]; then
    INIT="openrc"
elif command -v runit &>/dev/null && [ -d /run/runit ]; then
    INIT="runit"
elif command -v s6-rc &>/dev/null && [ -d /run/s6 ]; then
    INIT="s6"
elif [ "$(cat /proc/1/comm)" = "dinit" ]; then
    INIT="dinit"
else
    INIT="sysvinit"
fi

if command -v loginctl &>/dev/null; then
    HEEFT_LOGINCTL="true"
else
    HEEFT_LOGINCTL="false"
fi

mkdir -p "$QS_CONFIG_DIR"
echo "init= $INIT"                         > "$QS_CONFIG_DIR/system_info.txt"
echo "loginctl available= $HEEFT_LOGINCTL" >> "$QS_CONFIG_DIR/system_info.txt"

echo -e "${SUCCESS}✓ Init systeem gedetecteerd: $INIT${RESET}"
echo -e "${SUCCESS}✓ loginctl beschikbaar: $HEEFT_LOGINCTL${RESET}"

# ── 13. klaar ────────────────────────────────────────────────────

echo -e ""
if $IS_UPDATE; then
echo -e "╔══════════════════════════════════════╗"
echo -e "║   Update klaar!                      ║"
echo -e "╚══════════════════════════════════════╝"
else
echo -e "╔══════════════════════════════════════╗"
echo -e "║   Installatie klaar!                 ║"
echo -e "╚══════════════════════════════════════╝"
fi
echo -e ""