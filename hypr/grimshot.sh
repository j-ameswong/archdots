#!/bin/bash

# Directory to save screenshots
DIR="$HOME/Pictures"
mkdir -p "$DIR"

# Timestamp for filename
TIME=$(date +"%Y-%m-%d_%H-%M-%S")
FILE="$DIR/screenshot_$TIME.png"

# Check for optional argument
# "area" -> select a region, otherwise full screen
if [[ "$1" == "area" ]]; then
    grim -g "$(slurp)" "$FILE"
else
    grim "$FILE"
fi

# Copy to clipboard
wl-copy <"$FILE"

echo "Screenshot saved to $FILE and copied to clipboard."
