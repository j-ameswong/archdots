#!/bin/bash

# 1. Use zoxide to list directories and pipe to fzf
# We use --no-sort for fzf because zoxide already provides the list sorted by 'frecency'
SELECTED_DIR=$(zoxide query --list | fzf --height=40% --layout=reverse --border --prompt="🚀 Project > ")

# 2. Exit if the user cancelled fzf (pressed ESC or Ctrl+C)
if [[ -z "$SELECTED_DIR" ]]; then
    exit 0
fi

# 3. Generate a clean session name
# basename gets the folder name (e.g., /home/dev/cool-api -> cool-api)
# tr replaces dots with underscores to keep tmux happy
SESSION_NAME=$(basename "$SELECTED_DIR" | tr . _)

# 4. Check if we are currently inside tmux
if [[ -n "$TMUX" ]]; then
    # If inside tmux, we want to switch the current client to the new session
    CHANGE_CMD="switch-client"
else
    # If outside tmux, we want to attach to the session
    CHANGE_CMD="attach-session"
fi

# 5. Create the session if it doesn't exist
if ! tmux has-session -t="$SESSION_NAME" 2> /dev/null; then
    # Create a new detached session (-d) in the selected directory (-c)
    tmux new-session -d -s "$SESSION_NAME" -c "$SELECTED_DIR"
    
    # Send the 'nvim' command to the first window and press Enter (C-m)
    # This keeps the shell alive if you quit nvim later
    tmux send-keys -t "$SESSION_NAME" "nvim" C-m
fi

# 6. Attach to (or switch to) the session
tmux $CHANGE_CMD -t "$SESSION_NAME"
