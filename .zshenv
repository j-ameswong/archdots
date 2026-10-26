# ~/.zshenv — environment for ALL zsh shells (interactive, scripts, ssh).
# Interactive-only config lives in .zshrc.

# -U keeps entries unique, so nested shells can't duplicate PATH.
typeset -U path PATH

path=(
	$HOME/.local/bin
	$HOME/.local/share/gem/ruby/3.4.0/bin
	$HOME/.sdkman/candidates/java/current/bin
    $HOME/.opencode/bin
	$path
)

export SUDO_EDITOR=/usr/bin/nvim
export SDKMAN_DIR="$HOME/.sdkman"
export XDG_DATA_DIRS="$XDG_DATA_DIRS:/var/lib/flatpak/exports/share:home/contessa/.local/share/flatpak/exports/share"

[[ -f ~/.config/secrets/deepseek ]] && source ~/.config/secrets/deepseek
[[ -f ~/.config/secrets/openrouter ]] && source ~/.config/secrets/deepseek
