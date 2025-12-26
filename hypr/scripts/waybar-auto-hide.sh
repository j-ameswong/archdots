#!/bin/bash

# Configuration
TARGET_CLASS="kitty"
TARGET_TITLE_REGEX=".*Nvim.*"

# Variable to track if we hid the bar (to prevent desync)
HIDDEN_BY_SCRIPT=0

# Function to scan the current workspace for the target window
check_workspace() {
    # 1. Get the ID of the currently active workspace
    # We use activeworkspace so the bar reacts to the monitor/workspace you are currently focused on.
    local current_ws_id=$(hyprctl activeworkspace -j | jq -r '.id')

    # 2. Count windows on this workspace that match the criteria
    # We filter the clients list for:
    # - Workspace ID matching current workspace
    # - Class matching TARGET_CLASS
    # - Title matching TARGET_TITLE_REGEX
    local match_count=$(hyprctl clients -j | jq --arg cls "$TARGET_CLASS" \
                                                --arg regex "$TARGET_TITLE_REGEX" \
                                                --argjson ws "$current_ws_id" \
        'map(select(.workspace.id == $ws and .class == $cls and (.title | test($regex)))) | length')

    # 3. Toggle Waybar based on the count
    if [ "$match_count" -gt 0 ]; then
        # Nvim is present on this workspace
        if [ $HIDDEN_BY_SCRIPT -eq 0 ]; then
            killall -SIGUSR1 waybar
            HIDDEN_BY_SCRIPT=1
        fi
    else
        # Nvim is NOT present on this workspace
        if [ $HIDDEN_BY_SCRIPT -eq 1 ]; then
            killall -SIGUSR1 waybar
            HIDDEN_BY_SCRIPT=0
        fi
    fi
}

# Run the check immediately on startup (in case Nvim is already open)
check_workspace

# Listen to the Hyprland socket for relevant events
socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do 
    case "$line" in
        # Trigger check on:
        # - activewindow: Focus changes (in case we switch monitors)
        # - workspace: Switching workspaces
        # - open/close/move: Windows being created, killed, or moved around
        activewindow*|workspace*|openwindow*|closewindow*|movewindow*)
            check_workspace
            ;;
    esac
done
