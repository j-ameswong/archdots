#!/bin/bash
# --- CONFIGURATION ---
# Outputs that should all mirror the same wallpaper.
MONITORS=("eDP-1" "DP-5")
WALLPAPER_DIR="$HOME/Pictures/Wallpapers/"
CACHE_DIR="$HOME/.cache/awww"
CACHE_FILE="$CACHE_DIR/awww_current_index"
TRANSITION_DURATION=0.8
TRANSITIONS=("fade" "wave" "wipe" "grow" "outer" "left" "right")
# ---------------------

mkdir -p "$CACHE_DIR"

# 1. Ensure awww-daemon is running
if ! pgrep -x "awww-daemon" > /dev/null; then
    awww-daemon &
    sleep 1
fi

# 2. Pick the next image (shared by every monitor)
mapfile -t PICS < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" \) | sort -V)

if [ ${#PICS[@]} -eq 0 ]; then
    echo "No images found in $WALLPAPER_DIR, nothing to do."
    exit 1
fi

if [ -f "$CACHE_FILE" ]; then
    CURRENT_INDEX=$(cat "$CACHE_FILE")
else
    CURRENT_INDEX=-1
fi

NEXT_INDEX=$((CURRENT_INDEX + 1))
if [ $NEXT_INDEX -ge ${#PICS[@]} ]; then
    NEXT_INDEX=0
fi

NEXT_PIC="${PICS[$NEXT_INDEX]}"
RANDOM_TRANSITION=${TRANSITIONS[ $RANDOM % ${#TRANSITIONS[@]} ]}

# 3. Apply the same image + transition to every monitor
for OUTPUT in "${MONITORS[@]}"; do
    echo "[$OUTPUT] Setting wallpaper [$NEXT_INDEX/${#PICS[@]}]: $NEXT_PIC"
    awww img "$NEXT_PIC" \
        -o "$OUTPUT" \
        --transition-type "$RANDOM_TRANSITION" \
        --transition-duration "$TRANSITION_DURATION" \
        --transition-fps 60
done

echo "$NEXT_INDEX" > "$CACHE_FILE"
