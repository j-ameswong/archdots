#!/bin/bash

# --- CONFIGURATION ---
WALLPAPER_DIR="$HOME/Pictures/Wallpapers/"
CACHE_FILE="$HOME/.cache/awww_current_index"
TRANSITION_DURATION=0.8
TRANSITIONS=("fade" "wave" "wipe" "grow" "outer" "left" "right")
# ---------------------

# 1. Ensure awww-daemon is running
if ! pgrep -x "awww-daemon" > /dev/null; then
    awww-daemon &
    sleep 1
fi

# 2. Get list of images, sorted alphabetically (case-insensitive version sort)
# mapfile handles spaces in filenames correctly
mapfile -t PICS < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" \) | sort -V)

# Check if directory is empty
if [ ${#PICS[@]} -eq 0 ]; then
    echo "No images found in $WALLPAPER_DIR"
    exit 1
fi

# 3. Read the previous index from cache file
if [ -f "$CACHE_FILE" ]; then
    CURRENT_INDEX=$(cat "$CACHE_FILE")
else
    CURRENT_INDEX=-1
fi

# 4. Calculate next index
# increment by 1
NEXT_INDEX=$((CURRENT_INDEX + 1))

# If we reached the end of the list, loop back to 0
if [ $NEXT_INDEX -ge ${#PICS[@]} ]; then
    NEXT_INDEX=0
fi

# 5. Get the next wallpaper filename
NEXT_PIC="${PICS[$NEXT_INDEX]}"

# 6. Pick a random transition (optional, keeps it looking nice)
RANDOM_TRANSITION=${TRANSITIONS[ $RANDOM % ${#TRANSITIONS[@]} ]}

# 7. Apply wallpaper
echo "Setting wallpaper [$NEXT_INDEX/${#PICS[@]}]: $NEXT_PIC"
awww img "$NEXT_PIC" \
    --transition-type "grow" \
    --transition-duration "$TRANSITION_DURATION" \
    --transition-fps 60

# 8. Save the new index to the cache file for next time
echo "$NEXT_INDEX" > "$CACHE_FILE"
