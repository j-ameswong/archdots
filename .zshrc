# Clear the clipboard
wipe_clipboard() {
	cliphist wipe
	rm $HOME/.cache/cliphist/db
}
alias flush="wipe_clipboard"

# History used for auto-completions
HISTFILE=$HOME/.zsh_history
SAVEHIST=10000
HISTSIZE=10000
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Prompt with git
autoload -Uz vcs_info
precmd_functions+=(vcs_info)

zstyle ':vcs_info:git:*' formats '%b '
setopt PROMPT_SUBST
PROMPT='%F{green}%*%f %F{blue}%~%f %F{red}${vcs_info_msg_0_}%f$ '

# Better utils
alias grep="rg"
alias ls="eza"
alias ll="eza -l"
alias l="eza -al"
alias ff="fastfetch --logo $HOME/Pictures/Wallpapers/Kyubeymain.png --logo-type kitty-direct --logo-width 25 --logo-height 10"
alias ros-fix="sudo chown -R $USER:$USER ~/my_ros2_docker_workspace"

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk
# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Load completions
autoload -Uz compinit && compinit

# Add in snippets
zinit wait lucid for \
    OMZL::git.zsh \
    OMZP::git \
    OMZP::sudo \
    OMZP::archlinux \
    OMZP::aws \
    OMZP::kubectl \
    OMZP::kubectx \
    OMZP::command-not-found

zinit cdreplay

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

# nvim session with project selection via fzf
alias t="sh ~/.config/hypr/scripts/tmux_sesh_pick.sh"
alias tt="sh ~/.config/hypr/scripts/tmux.sh"

# Git helpers
hist() {
  # 1. Use fzf to find a file
  local file=$(fzf --preview 'git log --oneline --color=always -- {}')

  # 2. If a file was selected, run git log -p
  if [ -n "$file" ]; then
    git log -p -- "$file"
  fi
}
export PATH="$HOME/.local/bin:~/.local/share/gem/ruby/3.4.0/bin:$PATH"
export SUDO_EDITOR=/usr/bin/nvim

eval "$(mise activate zsh)"

[ -f "$HOME/.ghcup/env" ] && . "$HOME/.ghcup/env" # ghcup-env

alias qwen='
~/apps/llama.cpp/build/bin/llama-server \
  -m ./models/qwen2.5-coder-7b-q4_k_m.gguf \
  --port 8012 \
  -ngl 28 \
  -c 4096 \
  --fim-qwen-7b-default &
'

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
