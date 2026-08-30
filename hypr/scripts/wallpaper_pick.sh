#!/bin/bash
# Fuzzy wallpaper picker. Meant to be run inside a floating kitty window
# (see the kitty-special window rule in hyprland.lua), bound to SUPER + SHIFT + W.
#
# Selecting an entry sets the same wallpaper on every monitor via awww and
# keeps awww.sh's cycle index in sync, so SUPER + W continues from here.

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
CACHE_DIR="$HOME/.cache/awww"
CACHE_FILE="$CACHE_DIR/awww_current_index"
TRANSITION_DURATION=0.8
TRANSITIONS=("fade" "wave" "wipe" "grow" "outer" "left" "right")

# --- preview mode (re-entrant call from fzf) ---------------------------------
if [ "$1" = "--preview" ]; then
    img="$2"
    if [ -n "$KITTY_WINDOW_ID" ] && command -v kitten > /dev/null &&
        kitten icat --clear --transfer-mode=memory --stdin=no \
            --place="${FZF_PREVIEW_COLUMNS}x$((FZF_PREVIEW_LINES - 1))@${FZF_PREVIEW_LEFT}x${FZF_PREVIEW_TOP}" \
            "$img" 2>/dev/null; then
        : # rendered natively by kitty
    elif command -v chafa > /dev/null; then
        chafa -s "${FZF_PREVIEW_COLUMNS}x$((FZF_PREVIEW_LINES - 1))" "$img"
    else
        echo "$img"
    fi
    exit 0
fi
# -----------------------------------------------------------------------------

mkdir -p "$CACHE_DIR"

# Reveal the special workspace this window was assigned to. The window already
# exists at this point, so special.sh won't immediately toggle it back.
if command -v hyprctl > /dev/null; then
    if ! hyprctl monitors -j | jq -e '.[] | select(.specialWorkspace.name != "")' > /dev/null 2>&1; then
        hyprctl dispatch togglespecialworkspace > /dev/null
    fi
fi

mapfile -t PICS < <(find "$WALLPAPER_DIR" -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" \) | sort -V)

if [ ${#PICS[@]} -eq 0 ]; then
    echo "No images found in $WALLPAPER_DIR"
    read -r -n 1 -s
    exit 1
fi

CHOICE=$(printf '%s\n' "${PICS[@]}" \
    | fzf --prompt="  " \
          --header="Select a wallpaper" \
          --with-nth=-1 --delimiter=/ \
          --preview="$0 --preview {}" \
          --preview-window=right:60%:border-left \
          --reverse)

[ -z "$CHOICE" ] && exit 0

if ! pgrep -x "awww-daemon" > /dev/null; then
    awww-daemon &
    sleep 1
fi

RANDOM_TRANSITION=${TRANSITIONS[RANDOM % ${#TRANSITIONS[@]}]}

# No -o: awww applies the image to every output.
awww img "$CHOICE" \
    --transition-type "$RANDOM_TRANSITION" \
    --transition-duration "$TRANSITION_DURATION" \
    --transition-fps 60

# Keep awww.sh's cycle position aligned with what we just set.
for i in "${!PICS[@]}"; do
    if [ "${PICS[$i]}" = "$CHOICE" ]; then
        echo "$i" > "$CACHE_FILE"
        break
    fi
done
