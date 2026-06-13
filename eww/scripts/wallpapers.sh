#!/usr/bin/env bash

WP_DIR="$HOME/.config/wallpapers"
CURRENT_WP=$(cat "$HOME/.cache/wal/wal" 2>/dev/null)

case "$1" in
    list)
        echo -n "["
        first=true
        # Find all png, jpg, jpeg files in wallpapers directory
        for f in "$WP_DIR"/*.{png,jpg,jpeg}; do
            [ -e "$f" ] || continue
            if [ "$first" = true ]; then
                first=false
            else
                echo -n ","
            fi
            name=$(basename "$f")
            current="false"
            if [ "$f" = "$CURRENT_WP" ]; then
                current="true"
            fi
            # Escape paths for JSON
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
