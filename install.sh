#!/bin/bash

# ═══════════════════════════════════════════════════════════════
#  QuickShell installation & update script
#  Usage: bash install.sh
#  repo: https://github.com/amybronk/rice-land.git
#
#  This script is safe to run multiple times.
#  It installs on the first run, and updates on subsequent runs.
# ═══════════════════════════════════════════════════════════════

set -euo pipefail  # Exits on error, warns about undefined variables, catches pipeline errors

REPO_URL="https://github.com/amybronk/rice-land.git"

CONFIG_DIR="$HOME/.config"
QS_CONFIG_DIR="$CONFIG_DIR/quickshell"

# Fixed location where the repo will be cloned
REPO_DIR="$HOME/.local/share/quickshell-dotfiles"

# List of directories to symlink to ~/.config
FOLDERS=("quickshell" "hypr" "rofi" "matugen" "alacritty" "fastfetch" "fish")

# Wallpaper directories
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
PICTURES_DIR="$HOME/Pictures"
DEFAULT_PICTURES_DIR="$REPO_DIR/default pictures"

# ── ANSI Colors & Styles ────────────────────────────────────────
RESET="\033[0m"
BOLD="\033[1m"
GREEN="\033[32m"
ORANGE="\033[33m"
RED="\033[31m"
BLUE="\033[34m"

BOLDBLUE="${BOLD}${BLUE}"
SUCCESS="${BOLD}${GREEN}"
WARNING="${BOLD}${ORANGE}"
ERROR="${BOLD}${RED}"

# ── Detect if this is a first installation or an update ─────────
IS_UPDATE=false
if [ -d "$REPO_DIR/.git" ]; then
    IS_UPDATE=true
fi

echo -e "${BOLDBLUE}"
echo -e "╔══════════════════════════════════════╗"
if $IS_UPDATE; then
    echo -e "║   QuickShell Update                  ║"
else
    echo -e "║   QuickShell Installation            ║"
fi
echo -e "╚══════════════════════════════════════╝"
echo -e "${RESET}"

# ── 1. Check package manager ────────────────────────────────────
if ! command -v pacman &>/dev/null; then
    echo -e "${ERROR}✗ No supported package manager found (only pacman supported)${RESET}"
    exit 1
fi

# ── 2. Install git & flatpak ────────────────────────────────────
echo -e "${BLUE}>>> Installing Git & Flatpak (if needed)...${RESET}"

if ! command -v git &>/dev/null; then
    sudo pacman -S --needed --noconfirm git
    echo -e "${SUCCESS}✓ git installed${RESET}"
else
    echo -e "${SUCCESS}✓ git is already installed${RESET}"
fi

if ! command -v flatpak &>/dev/null; then
    sudo pacman -S --needed --noconfirm flatpak
    echo -e "${SUCCESS}✓ flatpak installed${RESET}"
else
    echo -e "${SUCCESS}✓ flatpak is already installed${RESET}"
fi

# ── 3. Install yay ──────────────────────────────────────────────
echo -e ""
echo -e "${BLUE}>>> Installing Yay (AUR helper) (if needed)...${RESET}"

if ! command -v yay &>/dev/null; then
    if ! pacman -Qe 2>/dev/null | grep -qw base-devel; then
        echo -e "  Installing base-devel..."
        sudo pacman -S --needed --noconfirm base-devel
    fi

    YAY_BUILD_DIR="/tmp/yay-build"
    rm -rf "$YAY_BUILD_DIR"
    git clone https://aur.archlinux.org/yay.git "$YAY_BUILD_DIR"

    ( cd "$YAY_BUILD_DIR" && makepkg -si --noconfirm )

    rm -rf "$YAY_BUILD_DIR"
    echo -e "${SUCCESS}✓ yay installed${RESET}"
else
    echo -e "${SUCCESS}✓ yay is already installed${RESET}"
fi

# ── 4. Clone or update repo ─────────────────────────────────────
echo -e ""
echo -e "${BLUE}>>> Fetching repo...${RESET}"

if [ -d "$REPO_DIR/.git" ]; then
    echo -e "  Forcing repo update..."
    echo -e "  ${WARNING}⚠ Warning: All local changes in the repo will be discarded!${RESET}"
    git -C "$REPO_DIR" fetch --all
    # Safe branch detection with fallback to 'main'
    DEFAULT_BRANCH=$(git -C "$REPO_DIR" symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
    git -C "$REPO_DIR" reset --hard "origin/$DEFAULT_BRANCH"
    echo -e "${SUCCESS}✓ Repo successfully force-updated${RESET}"
else
    mkdir -p "$(dirname "$REPO_DIR")"
    git clone "$REPO_URL" "$REPO_DIR"
    echo -e "${SUCCESS}✓ Repo cloned to $REPO_DIR${RESET}"
fi

# ── 5. Symlink config directories ───────────────────────────────
echo -e ""
echo -e "${BLUE}>>> Linking dotfiles...${RESET}"

for folder in "${FOLDERS[@]}"; do
    if [ -d "$REPO_DIR/$folder" ]; then
        mkdir -p "$CONFIG_DIR"

        if [ -d "$CONFIG_DIR/$folder" ] && [ ! -L "$CONFIG_DIR/$folder" ]; then
            BACKUP="$CONFIG_DIR/${folder}_backup_$(date +%Y%m%d_%H%M%S)"
            echo -e "  Backup created: $CONFIG_DIR/$folder → $BACKUP"
            mv "$CONFIG_DIR/$folder" "$BACKUP"
        fi

        ln -sf "$REPO_DIR/$folder" "$CONFIG_DIR/$folder"
        echo -e "  ${SUCCESS}✓ Linked: $folder → $CONFIG_DIR/$folder${RESET}"
    else
        echo -e "  ${WARNING}⚠ Directory '$folder' not found in repo, skipped${RESET}"
    fi
done

echo -e "${SUCCESS}✓ Dotfiles linked${RESET}"

# ── 6. Make scripts executable ──────────────────────────────────
echo -e ""
echo -e "${BLUE}>>> Making scripts executable...${RESET}"

find "$REPO_DIR" -name "*.sh" -exec chmod +x {} +
echo -e "${SUCCESS}✓ All .sh files in the repo made executable${RESET}"

# ── 7. Setup sudoers rule for shutdown ──────────────────────────
echo -e ""
echo -e "${BLUE}>>> Configuring sudoers for shutdown...${RESET}"

SUDOERS_BESTAND="/etc/sudoers.d/quickshell-shutdown"

if [ ! -f "$SUDOERS_BESTAND" ]; then
    # Use systemctl (default on modern Arch systems)
    echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/systemctl poweroff, /usr/bin/systemctl reboot" \
        | sudo tee "$SUDOERS_BESTAND" > /dev/null
    sudo chmod 440 "$SUDOERS_BESTAND"
    echo -e "${SUCCESS}✓ Sudoers rule added${RESET}"
else
    echo -e "${SUCCESS}✓ Sudoers rule already exists${RESET}"
fi

# ── 8. Create wallpaper directory (only on first install) ───────
if ! $IS_UPDATE; then
    echo -e ""
    echo -e "${BLUE}>>> Creating user directories...${RESET}"

    mkdir -p "$HOME/Music" "$HOME/Pictures" "$HOME/Videos" "$HOME/Downloads" \
             "$HOME/Desktop" "$HOME/Templates" "$HOME/Documents"

    echo -e "${SUCCESS}✓ User directories created${RESET}"
    echo -e ""
    echo -e "${BLUE}>>> Creating wallpaper directory...${RESET}"

    if [ ! -d "$WALLPAPER_DIR" ]; then
        mkdir -p "$WALLPAPER_DIR"

        # tr -d '[:space:]' prevents errors from spaces in wc -l output
        COPIED=$(find "$DEFAULT_PICTURES_DIR" -maxdepth 1 -type f \
            \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \
            -o -iname "*.webp" -o -iname "*.gif" -o -iname "*.bmp" \
            -o -iname "*.tiff" -o -iname "*.qoi" -o -iname "*.ico" \) \
            -exec cp {} "$WALLPAPER_DIR/" \; -print | wc -l | tr -d '[:space:]')

        if [ "$COPIED" -gt 0 ]; then
            echo -e "  ${SUCCESS}✓ $COPIED image(s) copied to $WALLPAPER_DIR${RESET}"
        else
            echo -e "  ${WARNING}⚠ No images found in $DEFAULT_PICTURES_DIR${RESET}"
            echo -e "    Add your own wallpapers to: $WALLPAPER_DIR"
        fi
        echo -e "${SUCCESS}✓ Wallpaper directory created: $WALLPAPER_DIR${RESET}"
    else
        echo -e "${SUCCESS}✓ Wallpaper directory already exists, skipped${RESET}"
    fi
fi

# ── 9. Update system ────────────────────────────────────────────
echo -e ""
echo -e "${BLUE}>>> Updating system...${RESET}"

# yay manages pacman, so direct pacman -Syu can cause conflicts
yay -Syu --noconfirm --ignore quickshell
echo -e "${SUCCESS}✓ System and AUR packages updated via yay${RESET}"

# ── 10. Install packages / rebuild quickshell ───────────────────
echo -e ""
echo -e "${BLUE}>>> Checking packages...${RESET}"

INSTALL_SCRIPT="$REPO_DIR/scripts/install_scripts/install-packages.sh"

if [ -f "$INSTALL_SCRIPT" ]; then
    chmod +x "$INSTALL_SCRIPT"
    bash "$INSTALL_SCRIPT"
else
    echo -e "  ${WARNING}⚠ install-packages.sh not found at: $INSTALL_SCRIPT${RESET}"
    echo -e "  Skipped manually."
fi

# Undefined QT_VERSION variables removed. Direct installation is safer.
yay -S --noconfirm quickshell
echo -e "${SUCCESS}✓ QuickShell is up-to-date/installed${RESET}"

# ── 10b. Configure Qt styles (qt5ct & qt6ct) ────────────────────
echo -e ""
echo -e "${BLUE}>>> Automating Qt styles (qt5ct & qt6ct)...${RESET}"

set_qtct_value() {
    local file="$1"
    local key="$2"
    local value="$3"

    mkdir -p "$(dirname "$file")"
    touch "$file"

    if ! grep -q "\[Appearance\]" "$file"; then
        echo -e "\n[Appearance]" >> "$file"
    fi

    sed -i "/^$key=/d" "$file"
    sed -i "/\[Appearance\]/a $key=$value" "$file"
}

QT5_CONF="$HOME/.config/qt5ct/qt5ct.conf"
QT6_CONF="$HOME/.config/qt6ct/qt6ct.conf"
SCHEME_PATH="$HOME/.local/share/color-schemes/Matugen-Base16.colors"

for conf in "$QT5_CONF" "$QT6_CONF"; do
    set_qtct_value "$conf" "style" "Breeze"
    set_qtct_value "$conf" "custom_palette" "false"
    set_qtct_value "$conf" "color_scheme_path" "$SCHEME_PATH"
done

echo -e "${SUCCESS}✓ qt5ct and qt6ct set to Breeze + Matugen-Base16${RESET}"

# ── 11. Reload Hyprland & start awww ────────────────────────────
echo -e ""
echo -e "${BLUE}>>> Reloading Hyprland & starting awww${RESET}"

if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ] && command -v hyprctl &>/dev/null; then
    if command -v awww-daemon &>/dev/null; then
        awww-daemon &
        sleep 0.2
    else
        echo -e "  ${WARNING}⚠ awww-daemon not found, skipped${RESET}"
    fi

    if [ -f "$WALLPAPER_DIR/pincones.jpg" ]; then
        sh "$REPO_DIR/scripts/backgroundSwicher/change_wallpaper.sh" "$WALLPAPER_DIR/pincones.jpg"
        echo -e "${SUCCESS}✓ Wallpaper set${RESET}"
    else
        echo -e "  ${WARNING}⚠ pincones.jpg not found, wallpaper skipped${RESET}"
    fi

    hyprctl reload
    echo -e "${SUCCESS}✓ Hyprland config reloaded${RESET}"
else
    echo -e "  ${WARNING}⚠ Hyprland is not running, reload skipped${RESET}"
    echo -e "    Restart Hyprland to load the new config"
fi

# ── 12. Detect init system ──────────────────────────────────────
echo -e ""
echo -e "${BLUE}>>> Detecting init system...${RESET}"

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
echo "init= $INIT" > "$QS_CONFIG_DIR/system_info.txt"
echo "loginctl available= $HEEFT_LOGINCTL" >> "$QS_CONFIG_DIR/system_info.txt"

echo -e "${SUCCESS}✓ Init system detected: $INIT${RESET}"
echo -e "${SUCCESS}✓ loginctl available: $HEEFT_LOGINCTL${RESET}"

# ── 13. Start applications ──────────────────────────────────────
echo -e ""
echo -e "${BLUE}>>> Starting applications...${RESET}"

QS &

# Safe shell change (prevents errors if fish is already set or missing)
CURRENT_SHELL=$(grep "^$USER:" /etc/passwd | cut -d: -f7)
if [ "$CURRENT_SHELL" != "/usr/bin/fish" ] && [ "$CURRENT_SHELL" != "/usr/local/bin/fish" ]; then
    echo -e "  Changing shell to fish..."
    chsh -s /usr/bin/fish 2>/dev/null || chsh -s /usr/local/bin/fish
    echo -e "  ${SUCCESS}✓ Shell set to fish${RESET}"
else
    echo -e "  ${SUCCESS}✓ Shell is already set to fish${RESET}"
fi

# ── 14. Done ────────────────────────────────────────────────────
echo -e ""
echo -e "${BOLDBLUE}"
if $IS_UPDATE; then
    echo -e "╔══════════════════════════════════════╗"
    echo -e "║   Update Complete!                   ║"
    echo -e "╚══════════════════════════════════════╝"
else
    echo -e "╔══════════════════════════════════════╗"
    echo -e "║   Installation Complete!             ║"
    echo -e "╚══════════════════════════════════════╝"
fi
echo -e "${RESET}"

if ! $IS_UPDATE; then
    echo -e ""
    echo -e "$(ERROR)"
    echo -e "Note: Restart your PC and then run the following command:"
    echo -e ""
    echo -e "bash $HOME/.local/share/quickshell-dotfiles/scripts/install_scripts/second_install_pkg.sh"
    echo -e ""
    echo -e "This installs the required Flatpaks for this project."
fi
echo -e "${RESET}"
