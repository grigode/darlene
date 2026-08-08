#!/usr/bin/env bash

WP_DIR="$HOME/.config/wallpapers"
CACHE_WAL="$HOME/.cache/wal/wal"

shopt -s nullglob

get_current_wp() {
    cat "$CACHE_WAL" 2>/dev/null
}

case "$1" in

    list)
        CURRENT_WP=$(get_current_wp)

        files=()

        # Wallpaper actual primero
        if [[ -n "$CURRENT_WP" && -f "$CURRENT_WP" ]]; then
            files+=("$CURRENT_WP")
        fi

        # Agregar wallpapers restantes
        for f in "$WP_DIR"/*.{png,jpg,jpeg,webp}; do
            [[ -f "$f" ]] || continue
            [[ "$f" == "$CURRENT_WP" ]] && continue

            files+=("$f")
        done

        echo -n "["

        first=true

        for f in "${files[@]}"; do
            name=$(basename "$f")

            current=false
            [[ "$f" == "$CURRENT_WP" ]] && current=true

            if [[ "$first" == true ]]; then
                first=false
            else
                echo -n ","
            fi

            jq -n \
                --arg path "$f" \
                --arg name "$name" \
                --argjson current "$current" \
                '{path:$path,name:$name,current:$current}' \
                | tr -d '\n'
        done

        echo "]"
        ;;


    open)
        # Bind temporal Escape
        hyprctl keyword bindn ", escape, exec, ~/.config/eww/scripts/wallpapers.sh close"

        # Navegación del selector
        hyprctl keyword bind ", left, sendshortcut, SHIFT, TAB, activewindow"
        hyprctl keyword bind ", right, sendshortcut, , TAB, activewindow"

        # Abrir selector
        eww close wallpaper-selector 2>/dev/null
        eww open wallpaper-selector
        ;;


    close)
        # Cerrar selector
        eww close wallpaper-selector 2>/dev/null || true

        # Limpiar binds temporales
        hyprctl keyword unbind ", escape"
        hyprctl keyword unbind ", left"
        hyprctl keyword unbind ", right"
        ;;


    select)
        wp_path="$2"

        if [[ -z "$wp_path" || ! -f "$wp_path" ]]; then
            exit 1
        fi

        CURRENT_WP=$(get_current_wp)

        # Si es el mismo wallpaper
        if [[ "$wp_path" == "$CURRENT_WP" ]]; then
            "$0" close
            exit 0
        fi

        # Aplicar wallpaper y colores
        wal -i "$wp_path"
        makoctl reload 2>/dev/null

        # Cerrar selector
        "$0" close

        # Recargar eww
        eww reload
        ;;


    *)
        echo "Uso: $0 {list|open|close|select <wallpaper>}"
        exit 1
        ;;

esac