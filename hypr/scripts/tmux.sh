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

# 4. Create the new session
# We no longer check "if ! has-session" because the loop above guarantees uniqueness
tmux new-session -d -s "$SESSION_NAME" -c "$SELECTED_DIR"

# Determine nvim command
if [[ -n "$SELECTED_FILE" ]]; then
    # We quote the file path to handle spaces safely
    CMD="nvim '$SELECTED_FILE'"
else
    CMD="nvim"
fi

# Send the command to tmux
tmux send-keys -t "$SESSION_NAME" "$CMD" C-m

# 5. Attach or Switch
if [[ -n "$TMUX" ]]; then
    tmux switch-client -t "$SESSION_NAME"
else
    tmux attach-session -t "$SESSION_NAME"
fi
