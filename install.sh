#!/bin/bash

# ═══════════════════════════════════════════════════════════════
#  QuickShell installatie & update script
#  Gebruik: bash install.sh
#  repo: https://github.com/amybronk/myquickshellwidget.git
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
# Voeg hier gewoon namen toe als je meer mappen aanmaakt
FOLDERS=("quickshell" "hypr" "rofi" "matugen")

# Wallpaper mappen — pas aan als jouw paden anders zijn
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
DEFAULT_PICTURES="$HOME/Pictures"

# ── detecteer of dit een eerste installatie of een update is ────

IS_UPDATE=false
if [ -d "$REPO_DIR/.git" ] && command -v yay &>/dev/null; then
    IS_UPDATE=true
fi

echo ""
echo "╔══════════════════════════════════════╗"
if $IS_UPDATE; then
echo "║   QuickShell update                  ║"
else
echo "║   QuickShell installatie             ║"
fi
echo "╚══════════════════════════════════════╝"
echo ""

# ── 1. package manager controleren ──────────────────────────────

if ! command -v pacman &>/dev/null; then
    echo "✗ Geen ondersteunde package manager gevonden (alleen pacman ondersteund)"
    exit 1
fi

# ── 2. git installeren ───────────────────────────────────────────

echo ">>> Git installeren (indien nodig)..."

if ! command -v git &>/dev/null; then
    sudo pacman -S --needed --noconfirm git
    echo "✓ git geïnstalleerd"
else
    echo "✓ git is al geïnstalleerd"
fi

# ── 3. yay installeren ───────────────────────────────────────────

echo ""
echo ">>> Yay (AUR helper) installeren (indien nodig)..."

if ! command -v yay &>/dev/null; then
    # base-devel is een pacman groep, niet een commando — check met pacman -Qq
    if ! pacman -Qq base-devel &>/dev/null 2>&1; then
        echo "  base-devel installeren..."
        sudo pacman -S --needed --noconfirm base-devel
    fi

    # Bouw in /tmp zodat er geen rommel achterblijft
    YAY_BUILD_DIR="/tmp/yay-build"
    rm -rf "$YAY_BUILD_DIR"
    git clone https://aur.archlinux.org/yay.git "$YAY_BUILD_DIR"

    # Subshell zodat cd de rest van het script niet beïnvloedt
    ( cd "$YAY_BUILD_DIR" && makepkg -si --noconfirm )

    rm -rf "$YAY_BUILD_DIR"
    echo "✓ yay geïnstalleerd"
else
    echo "✓ yay is al geïnstalleerd"
fi

# ── 4. repo clonen of updaten ────────────────────────────────────

echo ""
echo ">>> Repo ophalen..."

if [ -d "$REPO_DIR/.git" ]; then
    echo "  Repo updaten..."
    git -C "$REPO_DIR" pull
    echo "✓ Repo geüpdated"
else
    mkdir -p "$(dirname "$REPO_DIR")"
    git clone "$REPO_URL" "$REPO_DIR"
    echo "✓ Repo gecloned naar $REPO_DIR"
fi

# ── 5. config mappen linken ──────────────────────────────────────

echo ""
echo ">>> Dotfiles koppelen..."

for folder in "${FOLDERS[@]}"; do
    if [ -d "$REPO_DIR/$folder" ]; then

        mkdir -p "$CONFIG_DIR"

        # Backup maken als het een echte map is (geen symlink)
        if [ -e "$CONFIG_DIR/$folder" ] && [ ! -L "$CONFIG_DIR/$folder" ]; then
            BACKUP="$CONFIG_DIR/${folder}_backup_$(date +%Y%m%d_%H%M%S)"
            echo "  Backup gemaakt: $CONFIG_DIR/$folder → $BACKUP"
            mv "$CONFIG_DIR/$folder" "$BACKUP"
        fi

        ln -sf "$REPO_DIR/$folder" "$CONFIG_DIR/$folder"
        echo "  ✓ Gekoppeld: $folder → $CONFIG_DIR/$folder"
    else
        echo "  ⚠ Map '$folder' niet gevonden in repo, overgeslagen"
    fi
done

echo "✓ Dotfiles gekoppeld"

# ── 6. scripts uitvoerbaar maken ─────────────────────────────────

echo ""
echo ">>> Scripts uitvoerbaar maken..."

# Zoekt de hele repo door, alle submappen, onbeperkte diepte
find "$REPO_DIR" -name "*.sh" -exec chmod +x {} +
echo "✓ Alle .sh bestanden in de repo uitvoerbaar gemaakt"

# ── 7. sudoers regel voor shutdown ───────────────────────────────

echo ""
echo ">>> Sudoers instellen voor shutdown..."

SUDOERS_BESTAND="/etc/sudoers.d/quickshell-shutdown"

if [ ! -f "$SUDOERS_BESTAND" ]; then
    echo "$USER ALL=(ALL) NOPASSWD: /usr/sbin/shutdown" \
        | sudo tee "$SUDOERS_BESTAND" > /dev/null
    sudo chmod 440 "$SUDOERS_BESTAND"
    echo "✓ Sudoers regel toegevoegd"
else
    echo "✓ Sudoers regel bestaat al"
fi

# ── 8. wallpaper map aanmaken (alleen bij eerste installatie) ────

if ! $IS_UPDATE; then
    echo ""
    echo ">>> Wallpaper map aanmaken..."
 
    if [ ! -d "$WALLPAPER_DIR" ]; then
        mkdir -p "$WALLPAPER_DIR"
 
        # Kopieer alleen losse bestanden uit ~/Pictures (geen submappen)
        # -maxdepth 1 voorkomt dat wallpapers zichzelf probeert te kopiëren
        if [ -d "$DEFAULT_PICTURES" ]; then
            find "$DEFAULT_PICTURES" -maxdepth 1 -type f \
                \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \
                   -o -iname "*.webp" -o -iname "*.gif" -o -iname "*.jxl" \) \
                -exec cp {} "$WALLPAPER_DIR/" \;
            echo "  ✓ Bestaande fotos gekopieerd naar $WALLPAPER_DIR"
        fi
 
        # Verwijder de originele Pictures map (haal # weg om te activeren)
        # rm -rf "$DEFAULT_PICTURES"
 
        echo "✓ Wallpaper map aangemaakt: $WALLPAPER_DIR"
    else
        echo "✓ Wallpaper map bestaat al, overgeslagen"
    fi
fi

# ── 9. systeem updaten & Qt-versie bijhouden ─────────────────────
#
#  QuickShell (AUR) is gecompileerd tegen Qt. Als Qt een major of
#  minor versiesprong maakt (bijv. 6.7 → 6.8), werkt de bestaande
#  binary niet meer goed. We slaan de Qt-versie op vóór de update
#  en vergelijken daarna — als die verschilt, hercompileren we
#  quickshell automatisch.
# ─────────────────────────────────────────────────────────────────

echo ""
echo ">>> Systeem updaten..."

# Sla Qt-versie op vóór de update (major.minor, bijv. "6.7")
QT_VERSION_VOOR=$(pacman -Q qt6-base 2>/dev/null | awk '{print $2}' | cut -d. -f1,2 || echo "niet-geinstalleerd")

# Pacman systeem update
sudo pacman -Syu --noconfirm
echo "✓ Systeem geüpdated via pacman"

# Yay AUR update — quickshell wordt apart behandeld (zie stap 9)
yay -Syu --noconfirm --exclude quickshell
echo "✓ AUR pakketten geüpdated via yay"

# Sla Qt-versie op ná de update
QT_VERSION_NA=$(pacman -Q qt6-base 2>/dev/null | awk '{print $2}' | cut -d. -f1,2 || echo "niet-geinstalleerd")

echo ""
echo "  Qt versie vóór update : $QT_VERSION_VOOR"
echo "  Qt versie na update   : $QT_VERSION_NA"

# ── 10. packages installeren / quickshell hercompileren ───────────

echo ""
echo ">>> Packages controleren..."

INSTALL_SCRIPT="$REPO_DIR/scripts/install_scripts/install-packages.sh"

if [ -f "$INSTALL_SCRIPT" ]; then
    chmod +x "$INSTALL_SCRIPT"
    bash "$INSTALL_SCRIPT"
else
    echo "  ⚠ install-packages.sh niet gevonden op: $INSTALL_SCRIPT"
    echo "  Handmatig overgeslagen."
fi

# Hercompileer quickshell als Qt-versie veranderd is
if [ "$QT_VERSION_VOOR" != "$QT_VERSION_NA" ]; then
    echo ""
    echo ">>> Qt versie gewijzigd ($QT_VERSION_VOOR → $QT_VERSION_NA)"
    echo "    QuickShell hercompileren tegen nieuwe Qt..."
    yay -S --noconfirm --rebuild quickshell
    echo "✓ QuickShell hergecompileerd"
else
    # Gewone update als Qt niet veranderd is
    yay -S --noconfirm quickshell
    echo "✓ QuickShell is up-to-date"
fi

# ── 11. init systeem detecteren ──────────────────────────────────

echo ""
echo ">>> Init systeem detecteren..."

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

echo "✓ Init systeem gedetecteerd: $INIT"
echo "✓ loginctl beschikbaar: $HEEFT_LOGINCTL"

# ── 12. klaar ────────────────────────────────────────────────────

echo ""
if $IS_UPDATE; then
echo "╔══════════════════════════════════════╗"
echo "║   Update klaar!                      ║"
echo "╚══════════════════════════════════════╝"
else
echo "╔══════════════════════════════════════╗"
echo "║   Installatie klaar!                 ║"
echo "╚══════════════════════════════════════╝"
fi
echo ""
echo "Start QuickShell met:"
echo "  qs"
echo ""
echo "Of voeg dit toe aan je Hyprland config:"
echo "  exec-once = qs"
echo ""