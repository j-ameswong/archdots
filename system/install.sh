#!/bin/bash
# Deploy system-level config from this repo into /.
#
# Unlike the $HOME dotfiles in this repo -- which are symlinked -- these files
# are COPIED. A pacman hook is read by pacman as root and its Exec= line runs
# as root, so symlinking it to a file inside this user-writable git repo would
# mean anything able to write that file gets root on the next pacman run.
# /etc/snap-pac.ini is also in snap-pac's pacman backup= array, so pacman
# manages it with .pacnew semantics and would not behave predictably through
# a symlink.
#
# The cost of copying is that edits made on the live system do not flow back
# here automatically. Use `./system/install.sh --pull` to pick them up.
#
# Usage:
#   ./system/install.sh           deploy repo -> system (default)
#   ./system/install.sh --pull    copy live system files back into the repo
#   ./system/install.sh --diff    show what differs, change nothing

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/etc"

# "<path relative to etc/>:<mode to install with>"
FILES=(
    "pacman.d/hooks/99-secureboot-sign.hook:0644"
    "snap-pac.ini:0644"
    "snapper/configs/root:0640"
)

push() {
    local entry rel mode src dest
    for entry in "${FILES[@]}"; do
        rel="${entry%:*}"
        mode="${entry##*:}"
        src="$SRC_DIR/$rel"
        dest="/etc/$rel"

        if [[ ! -f "$src" ]]; then
            echo "missing in repo, skipping: $src" >&2
            continue
        fi

        if sudo cmp -s -- "$src" "$dest" 2>/dev/null; then
            echo "  unchanged  $dest"
            continue
        fi

        echo "  installing $dest ($mode)"
        sudo install -D -o root -g root -m "$mode" -- "$src" "$dest"
    done
}

pull() {
    local entry rel src dest
    for entry in "${FILES[@]}"; do
        rel="${entry%:*}"
        src="$SRC_DIR/$rel"
        dest="/etc/$rel"

        if [[ ! -e "$dest" ]]; then
            echo "not on system, skipping: $dest" >&2
            continue
        fi

        if sudo cmp -s -- "$src" "$dest" 2>/dev/null; then
            echo "  unchanged  $rel"
            continue
        fi

        echo "  pulling    $rel"
        mkdir -p -- "$(dirname -- "$src")"
        sudo cp -- "$dest" "$src"
        sudo chown "$(id -u):$(id -g)" -- "$src"
        chmod 0644 -- "$src"
    done
}

show_diff() {
    local entry rel src dest
    for entry in "${FILES[@]}"; do
        rel="${entry%:*}"
        src="$SRC_DIR/$rel"
        dest="/etc/$rel"

        if [[ ! -e "$dest" ]]; then
            echo "== $rel: not installed on system"
            continue
        fi
        if sudo cmp -s -- "$src" "$dest" 2>/dev/null; then
            echo "== $rel: in sync"
        else
            echo "== $rel: differs (repo < | system >)"
            sudo diff -- "$src" "$dest" || true
        fi
    done
}

case "${1:-}" in
    ""|--push)
        echo "Deploying system config to /etc ..."
        push
        echo "Done."
        ;;
    --pull)
        echo "Pulling system config into the repo ..."
        pull
        echo "Done. Review with: git diff"
        ;;
    --diff)
        show_diff
        ;;
    -h|--help)
        sed -n '2,19p' "${BASH_SOURCE[0]}" | sed 's/^# \?//'
        ;;
    *)
        echo "unknown option: $1" >&2
        echo "try: $0 --help" >&2
        exit 1
        ;;
esac
