export EDITOR=nvim

wipe_clipboard() {
	cliphist wipe
	rm $HOME/.cache/cliphist/db
}

HISTFILE=$HOME/.zsh_history
SAVEHIST=1
HISTSIZE=200

# Prompt
autoload -Uz vcs_info
precmd() { vcs_info }

zstyle ':vcs_info:git:*' formats '%b '
setopt PROMPT_SUBST
PROMPT='%F{green}%*%f %F{blue}%~%f %F{red}${vcs_info_msg_0_}%f$ '

alias grep="rg"
alias ls="eza"
alias ll="eza -al"
alias ff="fastfetch --logo /home/contessa/Pictures/Wallpapers/Kyubeymain.png --logo-type kitty-direct --logo-width 25 --logo-height 10"
