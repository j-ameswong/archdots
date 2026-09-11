# ~/.zshrc — interactive shell configuration.
# PATH and exported environment live in ~/.zshenv.

# ─── History ──────────────────────────────────────────────────────────────
HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory sharehistory hist_ignore_space
setopt hist_ignore_all_dups hist_save_no_dups hist_ignore_dups hist_find_no_dups

# ─── Prompt ───────────────────────────────────────────────────────────────
autoload -Uz vcs_info
precmd_functions+=(vcs_info)

zstyle ':vcs_info:git:*' formats '%b '
setopt PROMPT_SUBST
PROMPT='%F{green}%*%f %F{blue}%~%f %F{red}${vcs_info_msg_0_}%f$ '

# ─── Keybindings ──────────────────────────────────────────────────────────
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# ─── Completion styling ───────────────────────────────────────────────────
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --color=always $realpath'

# ─── Plugins (zinit) ──────────────────────────────────────────────────────
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"

if [[ ! -f $ZINIT_HOME/zinit.zsh ]]; then
	print -P "%F{33} %F{220}Installing zinit…%f"
	command mkdir -p "${ZINIT_HOME:h}" && command chmod g-rwX "${ZINIT_HOME:h}"
	command git clone https://github.com/zdharma-continuum/zinit "$ZINIT_HOME" && \
		print -P "%F{34} Installation successful.%f%b" || \
		print -P "%F{160} The clone has failed.%f%b"
fi

source "$ZINIT_HOME/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Everything below is deferred (wait lucid) so it loads just after the first
# prompt paints rather than blocking it. compinit rides along via atinit.
# Order matters: completions into fpath -> compinit -> fzf-tab -> autosuggestions
# -> syntax-highlighting last.
zinit ice wait lucid blockf
zinit light zsh-users/zsh-completions

zinit ice wait lucid atinit'zicompinit; zicdreplay'
zinit light Aloxaf/fzf-tab

zinit ice wait lucid atload'!_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions

zinit ice wait lucid
zinit light zsh-users/zsh-syntax-highlighting

zinit wait lucid for \
	OMZL::git.zsh \
	OMZP::git \
	OMZP::sudo \
	OMZP::archlinux \
	OMZP::aws \
	OMZP::kubectl \
	OMZP::kubectx \
	OMZP::command-not-found

# ─── Shell integrations ───────────────────────────────────────────────────
# Each of these normally costs a fork per shell to print its init script.
# Cache the output and re-generate only when the binary itself is newer.
_cached_eval() {
	local name=$1 bin=$2; shift 2
	local cache=${XDG_CACHE_HOME:-$HOME/.cache}/zsh/$name.zsh
	if [[ ! -s $cache || $commands[$bin] -nt $cache ]]; then
		command mkdir -p -- "${cache:h}"
		"$@" >| "$cache" 2>/dev/null || { rm -f -- "$cache"; return 1; }
	fi
	source "$cache"
}

# Safe to cache: these emit static, environment-independent init code.
_cached_eval fzf    fzf    fzf --zsh
_cached_eval zoxide zoxide zoxide init --cmd cd zsh

# NOT cacheable: `mise activate` emits a literal `export PATH=...` snapshot of
# the PATH at generation time, so a cached copy would freeze a stale PATH into
# every future shell. Worth the ~16ms fork.
# eval "$(mise activate zsh)"

[[ -f $HOME/.ghcup/env ]] && . "$HOME/.ghcup/env" # ghcup-env

# sdkman's init script costs ~23ms; load it only when `sdk` is first used.
# The java candidate is already on PATH via .zshenv, so this stays transparent.
sdk() {
	unfunction sdk
	source "$SDKMAN_DIR/bin/sdkman-init.sh"
	sdk "$@"
}

# ─── Aliases ──────────────────────────────────────────────────────────────
alias ls='eza'
alias ll='eza -l'
alias l='eza -al'
alias ff='fastfetch --logo "$HOME/Pictures/Wallpapers/Kyubeymain.png" --logo-type kitty-direct --logo-width 25 --logo-height 10'
alias ros-fix='sudo chown -R "$USER:$USER" "$HOME/my_ros2_docker_workspace"'

alias t='"$HOME/.config/hypr/scripts/tmux_sesh_pick.sh"'
alias tt='"$HOME/.config/hypr/scripts/tmux.sh"'

# ─── Functions ────────────────────────────────────────────────────────────

# Clear the clipboard and cliphist's backing database.
flush() {
	cliphist wipe
	rm -f -- "$HOME/.cache/cliphist/db"
}

# Pick a git-tracked file with fzf, then page through its full history.
hist() {
	local file
	file=$(git ls-files | fzf --preview 'git log --oneline --color=always -- {}') || return
	[[ -n $file ]] && git log -p -- "$file"
}

# Render a markdown file to HTML and open it in the browser.
md() {
	local input=$1 output
	if [[ -z $input ]]; then
		print -u2 "usage: md <file.md>"
		return 2
	fi
	if [[ ! -r $input ]]; then
		print -u2 "md: cannot read '$input'"
		return 1
	fi
	output=$(mktemp --suffix=.html) || return 1
	if ! pandoc -s --metadata title="${input:t}" -o "$output" -- "$input"; then
		rm -f -- "$output"
		return 1
	fi
	xdg-open "$output" >/dev/null 2>&1 &!
}

# Serve the local qwen coder model. Runs from the llama.cpp dir so the
# relative model path resolves regardless of the current directory.
qwen() {
	local root=$HOME/apps/llama.cpp
	local model=$root/models/ggml-vocab-qwen2.gguf
	if [[ ! -r $model ]]; then
		print -u2 "qwen: model not found at $model"
		return 1
	fi
	"$root/build/bin/llama-server" \
		-m "$model" \
		--port 8012 \
		-ngl 28 \
		-c 2048 \
		--fim-qwen-7b-default "$@"
}

# tmux cheat sheet. Covers the bindings from ~/.tmux.conf.local plus the Oh my
# tmux! ones worth remembering; `<prefix> ?` lists everything tmux knows.
thelp() {
	local -a help=(
		""
		"%F{blue}%Btmux keybindings%b%f — prefix is %F{yellow}C-b%f, or %F{yellow}C-a%f"
		""
		"%F{green}%BMine%b%f%F{242} (~/.tmux.conf.local)%f"
		"  %F{yellow}<prefix> S%f      create a session, or attach if it exists"
		"  %F{yellow}<prefix> b%f      toggle the status bar"
		"  %F{yellow}<prefix> C-k%f    kill the session"
		"  %F{yellow}<prefix> x%f      kill the window"
		""
		"%F{green}%BSessions%b%f"
		"  %F{yellow}<prefix> C-c%f    new session"
		"  %F{yellow}<prefix> C-f%f    find a session by name and switch to it"
		"  %F{yellow}<prefix> S-Tab%f  last session"
		"  %F{yellow}<prefix> s%f      pick a session from a tree"
		"  %F{yellow}<prefix> d%f      detach"
		""
		"%F{green}%BWindows%b%f"
		"  %F{yellow}<prefix> c%f      new window"
		"  %F{yellow}<prefix> ,%f      rename window"
		"  %F{yellow}<prefix> 0-9%f    select window by number"
		"  %F{yellow}<prefix> w%f      pick a window from a tree"
		"  %F{yellow}<prefix> Tab%f    last window"
		"  %F{yellow}<prefix> C-h/C-l%f  previous / next window"
		"  %F{yellow}<prefix> C-S-H/L%f  move the window left / right"
		""
		"%F{green}%BPanes%b%f"
		"  %F{yellow}<prefix> -%f      split below"
		"  %F{yellow}<prefix> _%f      split to the right"
		"  %F{yellow}<prefix> h j k l%f  move between panes"
		"  %F{yellow}<prefix> H J K L%f  resize, repeatable"
		"  %F{yellow}<prefix> < >%f    swap with the previous / next pane"
		"  %F{yellow}<prefix> +%f      maximise this pane, again to restore"
		"  %F{yellow}<prefix> z%f      zoom this pane"
		"  %F{yellow}<prefix> q%f      show pane numbers"
		""
		"%F{green}%BCopy mode%b%f%F{242} (vi keys)%f"
		"  %F{yellow}<prefix> Enter%f  enter copy mode"
		"  %F{yellow}v%f / %F{yellow}C-v%f       start selection / toggle rectangle"
		"  %F{yellow}y%f / %F{yellow}Escape%f    copy and exit / cancel"
		"  %F{yellow}H%f / %F{yellow}L%f         start / end of line"
		"  %F{yellow}<prefix> p%f      paste the top buffer"
		"  %F{yellow}<prefix> P%f      choose which buffer to paste"
		""
		"%F{green}%BMisc%b%f"
		"  %F{yellow}<prefix> m%f      toggle mouse mode"
		"  %F{yellow}<prefix> e%f      edit ~/.tmux.conf.local, then reload"
		"  %F{yellow}<prefix> r%f      reload the config"
		"  %F{yellow}C-l%f            clear the screen and the scrollback"
		"  %F{yellow}<prefix> ?%f      list every binding"
		""
	)
	print -Pl -- "${help[@]}"
}
