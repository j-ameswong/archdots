#!/bin/bash
# --- CONFIGURATION ---
# One entry per monitor. Format: "output_name:wallpaper_dir"
MONITORS=(
    "eDP-1:$HOME/Pictures/Wallpapers/"
    "DP-5:$HOME/Pictures/Wallpapers/"
)
CACHE_DIR="$HOME/.cache/awww"
TRANSITION_DURATION=0.8
TRANSITIONS=("fade" "wave" "wipe" "grow" "outer" "left" "right")
# ---------------------

mkdir -p "$CACHE_DIR"

# 1. Ensure awww-daemon is running (only needs to happen once, not per-monitor)
if ! pgrep -x "awww-daemon" > /dev/null; then
    awww-daemon &
    sleep 1
fi

# 2. Loop over each configured monitor
for ENTRY in "${MONITORS[@]}"; do
    OUTPUT="${ENTRY%%:*}"       # everything before the first ':'
    WALLPAPER_DIR="${ENTRY#*:}" # everything after the first ':'
    CACHE_FILE="$CACHE_DIR/awww_current_index_${OUTPUT}"

    # Get list of images for this monitor's directory
    mapfile -t PICS < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" \) | sort -V)

    if [ ${#PICS[@]} -eq 0 ]; then
        echo "No images found in $WALLPAPER_DIR for $OUTPUT, skipping."
        continue
    fi

    # Read previous index for THIS monitor
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

    echo "[$OUTPUT] Setting wallpaper [$NEXT_INDEX/${#PICS[@]}]: $NEXT_PIC"
    awww img "$NEXT_PIC" \
        -o "$OUTPUT" \
        --transition-type "$RANDOM_TRANSITION" \
        --transition-duration "$TRANSITION_DURATION" \
        --transition-fps 60

    echo "$NEXT_INDEX" > "$CACHE_FILE"
done
