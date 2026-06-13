#!/usr/bin/env bash

TIMER_FILE="/tmp/eww-osd.timer"

get_volume() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}'
}

is_volume_muted() {
    if wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q "MUTED"; then
        echo "true"
    else
        echo "false"
    fi
}

get_brightness() {
    # Handles both intel_backlight and generic backlight devices
    brightnessctl -m | head -n1 | cut -d, -f4 | tr -d '%'
}

is_mic_muted() {
    if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q "MUTED"; then
        echo "true"
    else
        echo "false"
    fi
}

ACTION=$1
VALUE=$2

case "$ACTION" in
    volume)
        if [ "$VALUE" = "mute" ]; then
            wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        else
            wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ "$VALUE"
        fi
        
        VOL=$(get_volume)
        MUTED=$(is_volume_muted)
        
        ICON="󰕾"
        if [ "$MUTED" = "true" ] || [ "$VOL" -eq 0 ]; then
            ICON="󰝟"
            VOL=0
        elif [ "$VOL" -lt 30 ]; then
            ICON="󰕿"
        elif [ "$VOL" -lt 70 ]; then
            ICON="󰖀"
        fi
        
        eww update osd_type="volume" osd_value="$VOL" osd_icon="$ICON" osd_mic_muted=false osd_visible=true
        ;;
        
    brightness)
        brightnessctl set "$VALUE"
        BRIGHT=$(get_brightness)
        
        ICON="󰃠"
        if [ "$BRIGHT" -lt 30 ]; then
            ICON="󰃞"
        elif [ "$BRIGHT" -lt 70 ]; then
            ICON="󰃟"
        fi
        
        eww update osd_type="brightness" osd_value="$BRIGHT" osd_icon="$ICON" osd_mic_muted=false osd_visible=true
        ;;
        
    mic)
        if [ "$VALUE" = "mute" ] || [ -z "$VALUE" ]; then
            wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
        fi
        
        MUTED=$(is_mic_muted)
        
        ICON="󰍬"
        if [ "$MUTED" = "true" ]; then
            ICON="󰍭"
        fi
        
        eww update osd_type="mic" osd_value=0 osd_icon="$ICON" osd_mic_muted="$MUTED" osd_visible=true
        ;;
esac

# Open window if not already open
eww open osd

# Handle auto-close timer
TOKEN=$(date +%s%N)
echo "$TOKEN" > "$TIMER_FILE"

sleep 2

# If no newer action has overwritten the token, trigger exit animation and close
if [ "$(cat "$TIMER_FILE" 2>/dev/null)" = "$TOKEN" ]; then
    eww update osd_visible=false
    sleep 0.25 # Wait for exit animation
    # Verify the token is still ours before closing the window
    if [ "$(cat "$TIMER_FILE" 2>/dev/null)" = "$TOKEN" ]; then
        eww close osd
    fi
fi
