#!/usr/bin/env bash

WP_DIR="$HOME/.config/wallpapers"
CURRENT_WP=$(cat "$HOME/.cache/wal/wal" 2>/dev/null)

case "$1" in
    list)
        files=()

        # Agregar primero el wallpaper actual
        if [ -n "$CURRENT_WP" ] && [ -f "$CURRENT_WP" ]; then
            files+=("$CURRENT_WP")
        fi

        # Agregar el resto evitando duplicados
        for f in "$WP_DIR"/*.{png,jpg,jpeg}; do
            [ -e "$f" ] || continue
            [ "$f" = "$CURRENT_WP" ] && continue
            files+=("$f")
        done

        echo -n "["
        first=true

        for f in "${files[@]}"; do
            if [ "$first" = true ]; then
                first=false
            else
                echo -n ","
            fi

            name=$(basename "$f")

            current=false
            [ "$f" = "$CURRENT_WP" ] && current=true

            echo -n "{\"path\":\"$f\",\"name\":\"$name\",\"current\":$current}"
        done

        echo "]"
        ;;
    open)
        # Dynamically bind Escape to close the selector
        hyprctl keyword bindn , escape, exec, ~/.config/eww/scripts/wallpapers.sh close
        
        # Dynamically bind Left/Right arrows to emulate Tab focus switching
        hyprctl keyword bind , left, sendshortcut, SHIFT, TAB, activewindow
        hyprctl keyword bind , right, sendshortcut, , TAB, activewindow
        
        # Open the selector window
        eww close wallpaper-selector 2>/dev/null
        sleep 0.1
        eww open wallpaper-selector
        ;;
    close)
        # Close the window if open
        eww close wallpaper-selector 2>/dev/null || true
        # Dynamically unbind keys
        hyprctl keyword unbind , escape
        hyprctl keyword unbind , left
        hyprctl keyword unbind , right
        ;;
    select)
        wp_path="$2"
        if [ "$wp_path" = "$CURRENT_WP" ]; then
            ~/.config/eww/scripts/wallpapers.sh close
            exit 0
        fi
        # Run pywal to generate colors and set wallpaper
        wal -i "$wp_path"
        # Close window and unbind keys
        ~/.config/eww/scripts/wallpapers.sh close
        # Reload eww so it registers the new colors immediately
        eww reload
        ;;
esac
