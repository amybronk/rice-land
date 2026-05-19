#!/bin/bash

if [ -z "$1" ]; then
    echo "Gebruik: $0 /pad/naar/achtergrond.jpg"
    exit 1
fi

WALLPAPER=$1

# 1. Hyprpaper achtergrond aanpassen
# We moeten de afbeelding eerst 'preloaden' en dan pas 'setten'
hyprctl hyprpaper preload "$WALLPAPER"
# Vervang 'eDP-1' door jouw monitor naam (check via 'hyprctl monitors')
hyprctl hyprpaper wallpaper "eDP-1,$WALLPAPER"

# 2. Matugen kleuren genereren
matugen image "$WALLPAPER"

# 3. Oude preloads opruimen in hyprpaper (optioneel, bespaart RAM)
hyprctl hyprpaper unload all

# ... (in je script nadat matugen heeft gedraaid)
matugen image "$WALLPAPER"

# Herlaad hyprland zonder herstart
hyprctl reload