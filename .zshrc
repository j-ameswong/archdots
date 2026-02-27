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
precmd() { vcs_info }

zstyle ':vcs_info:git:*' formats '%b '
setopt PROMPT_SUBST
PROMPT='%F{green}%*%f %F{blue}%~%f %F{red}${vcs_info_msg_0_}%f$ '

# Better utils
alias grep="rg"
alias ls="eza"
alias ll="eza -l"
alias l="eza -al"
alias ff="fastfetch --logo /home/contessa/Pictures/Wallpapers/Kyubeymain.png --logo-type kitty-direct --logo-width 25 --logo-height 10"
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
bindkey '^n' history-sea

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'rch-forward -q

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
export MISE_SHELL=bash
export SUDO_EDITOR=/usr/bin/nvim

# On first activation, save the original PATH
# On re-activation, we keep the saved original
if [ -z "${__MISE_ORIG_PATH:-}" ]; then
  export __MISE_ORIG_PATH="$PATH"
fi

mise() {
  local command
  command="${1:-}"
  if [ "$#" = 0 ]; then
    command mise
    return
  fi
  shift

  case "$command" in
  deactivate|shell|sh)
    # if argv doesn't contains -h,--help
    if [[ ! " $@ " =~ " --help " ]] && [[ ! " $@ " =~ " -h " ]]; then
      eval "$(command mise "$command" "$@")"
      return $?
    fi
    ;;
  esac
  command mise "$command" "$@"
}

_mise_hook() {
  local previous_exit_status=$?;
  eval "$(mise hook-env -s bash)";
  return $previous_exit_status;
};
if [[ ";${PROMPT_COMMAND:-};" != *";_mise_hook;"* ]]; then
  PROMPT_COMMAND="_mise_hook${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
fi
# shellcheck shell=bash
export -a chpwd_functions
function __zsh_like_cd()
{
  \typeset __zsh_like_cd_hook
  if
    builtin "$@"
  then
    for __zsh_like_cd_hook in chpwd "${chpwd_functions[@]}"
    do
      if \typeset -f "$__zsh_like_cd_hook" >/dev/null 2>&1
      then "$__zsh_like_cd_hook" || break # finish on first failed hook
      fi
    done
    true
  else
    return $?
  fi
}

# shellcheck shell=bash
[[ -n "${ZSH_VERSION:-}" ]] ||
{
  function cd()    { __zsh_like_cd cd    "$@" ; }
  function popd()  { __zsh_like_cd popd  "$@" ; }
  function pushd() { __zsh_like_cd pushd "$@" ; }
}

chpwd_functions+=(_mise_hook)
_mise_hook
if [ -z "${_mise_cmd_not_found:-}" ]; then
    _mise_cmd_not_found=1
    if [ -n "$(declare -f command_not_found_handle)" ]; then
        _mise_cmd_not_found_handle=$(declare -f command_not_found_handle)
        eval "${_mise_cmd_not_found_handle/command_not_found_handle/_command_not_found_handle}"
    fi

    command_not_found_handle() {
        if [[ "$1" != "mise" && "$1" != "mise-"* ]] && mise hook-not-found -s bash -- "$1"; then
          _mise_hook
          "$@"
        elif [ -n "$(declare -f _command_not_found_handle)" ]; then
            _command_not_found_handle "$@"
        else
            echo "bash: command not found: $1" >&2
            return 127
        fi
    }
fi

[ -f "/home/contessa/.ghcup/env" ] && . "/home/contessa/.ghcup/env" # ghcup-env
# errwatch: capture stderr and report outcomes to daemon

#_ERRWATCH_STDERR="/tmp/errwatch_stderr_$$"  # $$ = this shell's PID
#_ERRWATCH_ORIG_FD=

# Runs before each command — save fd2 and redirect stderr to capture file
#preexec() {
#   > "$_ERRWATCH_STDERR"
#   exec {_ERRWATCH_ORIG_FD}>&2
#   exec 2>>"$_ERRWATCH_STDERR"
# }

# Runs after each command — restore stderr, display any captured output, notify daemon
#precmd() {
#  local exit_code=$?
#  local had_stderr=0
#
#  if [[ -n "$_ERRWATCH_ORIG_FD" ]]; then
#    exec 2>&"$_ERRWATCH_ORIG_FD" {_ERRWATCH_ORIG_FD}>&-
#    _ERRWATCH_ORIG_FD=
#    if [[ -s "$_ERRWATCH_STDERR" ]]; then
#      had_stderr=1
#      cat "$_ERRWATCH_STDERR" >&2
#    fi
#  fi
#
#  errwatch-notify "$exit_code" "$had_stderr"
#}
#
## Clean up temp file when shell exits
#zshexit() {
#  rm -f "$_ERRWATCH_STDERR"
#}
