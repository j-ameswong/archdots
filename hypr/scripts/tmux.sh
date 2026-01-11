#!/bin/bash

# 1. Select Directory
# Use zoxide to list directories and pipe to fzf
SELECTED_DIR=$(zoxide query --list | fzf --height=100% --layout=reverse --border --prompt="Project > ")

# Exit if the user cancelled directory selection
if [[ -z "$SELECTED_DIR" ]]; then
    exit 0
fi

# 2. Select File (Optional)
# We enter the directory temporarily so fzf shows relative paths
pushd "$SELECTED_DIR" > /dev/null

# Use a subshell or a listing command. 
if command -v fd > /dev/null; then
    LIST_CMD="fd --type f --hidden --follow --exclude .git"
else
    LIST_CMD="find . -type f -not -path '*/.*'"
fi

SELECTED_FILE=$(eval "$LIST_CMD" | fzf --height=100% --layout=reverse --border --prompt="File (Esc to skip) > ")

# We leave the directory to return to the script's original context
popd > /dev/null

# --------------------------------

# 3. Generate Unique Session Name
# Start with the base folder name
BASE_SESSION_NAME=$(basename "$SELECTED_DIR" | tr . _)
SESSION_NAME="$BASE_SESSION_NAME"
COUNTER=1

# Check if session exists; if so, append a number and increment until unique
while tmux has-session -t="$SESSION_NAME" 2> /dev/null; do
    SESSION_NAME="${BASE_SESSION_NAME}-${COUNTER}"
    ((COUNTER++))
done

# Determine nvim command
if [[ -n "$SELECTED_FILE" ]]; then
    CMD="nvim '$SELECTED_DIR/$SELECTED_FILE'"
else
    CMD="nvim '$SELECTED_DIR'"
fi

# 4 & 5. Attach, Switch, or Split
if [[ -n "$TMUX" ]]; then
    # We are inside tmux: Open a new pane in the current window
    # -c sets the start directory, -h for horizontal split (change to -v for vertical)
    tmux new-window -c "$SELECTED_DIR" -n "nvim" "$CMD"
else
    # We are outside tmux: Create a new session and attach
    tmux new-session -d -s "$SESSION_NAME" -c "$SELECTED_DIR"
    tmux send-keys -t "$SESSION_NAME" "$CMD" C-m
    tmux attach-session -t "$SESSION_NAME"
fi
