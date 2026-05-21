#!/usr/bin/env bash

# 1. Start de awww daemon op de achtergrond
awww-daemon &

# 2. Geef de daemon heel even de tijd om op te starten (0.2 seconden is vaak zat)
sleep 0.2

# 3. Bepaal de locatie van je cache-bestand en een fallback wallpaper
CACHE_FILE="$HOME/.cache/current_wallpaper"
DEFAULT_WALLPAPER="$HOME/Pictures/Wallpapers/default.jpg"

# 4. Check of het cache-bestand bestaat en laad de wallpaper in
if [ -f "$CACHE_FILE" ]; then
    SAVED_WALLPAPER=$(cat "$CACHE_FILE")
    # Controleer of het bestand dat in de cache staat ook écht nog bestaat
    if [ -f "$SAVED_WALLPAPER" ]; then
        awww img "$SAVED_WALLPAPER" --transition-type none

        matugen image "$SAVED_WALLPAPER"
    
    else
        awww img "$DEFAULT_WALLPAPER" --transition-type none

        matugen image "$DEFAULT_WALLPAPER"
    fi
else
    awww img "$DEFAULT_WALLPAPER" --transition-type none

    matugen image "$DEFAULT_WALLPAPER"

fi

