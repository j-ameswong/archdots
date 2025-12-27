#!/bin/bash
# Get existing sessions or "New Session" option
choice=$(tmux list-sessions -F "#S" 2>/dev/null | fzf --header="Select Tmux Session" --print-query | tail -1)

if [ -n "$choice" ]; then
    tmux has-session -t "$choice" 2>/dev/null || tmux new-session -d -s "$choice"
    tmux attach-session -t "$choice"
fi
