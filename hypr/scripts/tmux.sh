#!/bin/bash

# Use zoxide to list directories and pipe to fzf
SELECTED_DIR=$(zoxide query --list | fzf --height=100% --layout=reverse --border --prompt="Project > ")

# Exit if the user cancelled directory selection
if [[ -z "$SELECTED_DIR" ]]; then
    exit 0
fi

# We enter the directory temporarily so fzf shows relative paths (e.g., "src/main.rs" instead of "/home/user/...")
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

# 3. Generate session name
SESSION_NAME=$(basename "$SELECTED_DIR" | tr . _)

# 4. Check if we are currently inside tmux
if [[ -n "$TMUX" ]]; then
    CHANGE_CMD="switch-client"
else
    CHANGE_CMD="attach-session"
fi

# Create the session if it doesn't exist
if ! tmux has-session -t="$SESSION_NAME" 2> /dev/null; then
    # Create detached session
    tmux new-session -d -s "$SESSION_NAME" -c "$SELECTED_DIR"
    
    # Determine nvim command: 
    # If a file was picked, open it. Otherwise just open nvim in the cwd.
    if [[ -n "$SELECTED_FILE" ]]; then
        # We quote the file path to handle spaces safely
        CMD="nvim '$SELECTED_FILE'"
    else
        CMD="nvim"
    fi

    # Send the command to tmux
    tmux send-keys -t "$SESSION_NAME" "$CMD" C-m
fi

# Attach/Switch
tmux $CHANGE_CMD -t "$SESSION_NAME"
