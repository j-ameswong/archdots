#!/bin/bash
# monitor-special.sh
handle() {
  case $1 in
    # Listen for workspace changes or window closes
    workspace*|closewindow*)
      # Count windows in the special workspace
      WINDOW_COUNT=$(hyprctl workspaces -j | jq '.[] | select(.name == "special") | .windows')
      
      # If count is 0, switch back to a regular workspace (e.g., workspace 1)
      if [ "$WINDOW_COUNT" -eq 0 ]; then
        hyprctl dispatch togglespecialworkspace
      fi
      ;;
  esac
}

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle "$line"; done
