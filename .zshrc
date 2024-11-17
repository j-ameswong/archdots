# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Lines configured by zsh-newuser-install
unsetopt beep

source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

alias pkg_backup="pacman -Qqe > pkglist.txt"
pkg_install() {
    (comm -12 <(pacman -Slq | sort) <(sort pkglist.txt)) > pkginstall.txt
}

wipe_clipboard() {
    cliphist wipe
    rm ~/.cache/cliphist/db
}

alias neofetch="fastfetch"
alias cliphistwipe = "wipe_clipboard"
