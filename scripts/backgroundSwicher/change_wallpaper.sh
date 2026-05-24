#!/usr/bin/env bash

# 1. Controleer of er wel een pad is meegegeven als argument
if [ -z "$1" ]; then
    echo "Fout: Geen afbeelding meegegeven!"
    echo "Gebruik: $0 /pad/naar/achtergrond.jpg"
    exit 1
fi

# $1 is het eerste argument dat je meegeeft achter het script
WALLPAPER="$1"

# 2. Controleer of het bestand daadwerkelijk bestaat voor we doorgaan
if [ ! -f "$WALLPAPER" ]; then
    echo "Fout: Bestand '$WALLPAPER' bestaat niet."
    exit 1
fi

# 3. De wallpaper veranderen met awww (met een mooie transitie)
awww img "$WALLPAPER" --transition-type grow --transition-fps 60 --transition-duration 5

# 4. Het pad opslaan in de cache voor de volgende opstart (reboot-safe)
echo "$WALLPAPER" > "$HOME/.cache/current_wallpaper"

# 5. Matugen kleuren genereren op basis van de nieuwe wallpaper
matugen image "$WALLPAPER" --prefer=saturation

# 6. Hyprland herladen zodat eventuele nieuwe kleuren direct worden toegepast
hyprctl reload

echo "Wallpaper succesvol veranderd naar: $WALLPAPER"