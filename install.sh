#!/usr/bin/env bash
# Terminal setup installer: Ghostty + bash (ble.sh, starship, atuin, fzf…) + tmux + TUI apps.
#
#   ./install.sh               everything (asks for sudo for dnf)
#   ./install.sh --links       only (re)create the config symlinks
#   ./install.sh --no-packages skip dnf (binaries, plugins and links only)
#   ./install.sh --update      also re-download the GitHub binaries if already installed
#
# Safe to run again: existing files are moved to ~/.dotfiles-backup/<timestamp>/ before
# being replaced, and links that already point here are left alone.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN="$HOME/.local/bin"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
DO_PACKAGES=1 DO_BINARIES=1 DO_PLUGINS=1 UPDATE=0
TMP_DIRS=()
trap '[ ${#TMP_DIRS[@]} -eq 0 ] || rm -rf "${TMP_DIRS[@]}"' EXIT

for arg in "$@"; do
    case "$arg" in
        --links) DO_PACKAGES=0 DO_BINARIES=0 DO_PLUGINS=0 ;;
        --no-packages) DO_PACKAGES=0 ;;
        --update) UPDATE=1 ;;
        -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
        *) echo "unknown option: $arg" >&2; exit 2 ;;
    esac
done

say()  { printf '\033[1;35m==>\033[0m %s\n' "$*"; }
ok()   { printf '  \033[32m✓\033[0m %s\n' "$*"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[31merror:\033[0m %s\n' "$*" >&2; exit 1; }

# ── 1. Packages ─────────────────────────────────────────────────────────
install_packages() {
    command -v dnf >/dev/null || die "dnf not found: this installer targets Fedora"
    say "Fedora packages (sudo)"
    if ! command -v ghostty >/dev/null; then
        sudo dnf copr enable -y scottames/ghostty
        sudo dnf install -y ghostty
    fi
    mapfile -t pkgs < <(grep -vE '^\s*(#|$)' "$DOTFILES/packages.txt")
    sudo dnf install -y "${pkgs[@]}"
    ok "${#pkgs[@]} packages"
}

# ── 2. Binaries not packaged in Fedora (GitHub releases, checksum-verified) ──
gh_release() { # repo [tag] -> release JSON
    local url="https://api.github.com/repos/$1/releases/${2:+tags/}${2:-latest}"
    curl -fsSL -H 'Accept: application/vnd.github+json' "$url"
}

fetch_verified() { # json asset_name dest_file
    local json=$1 name=$2 dest=$3 url digest
    url=$(jq -r --arg n "$name" '.assets[] | select(.name==$n) | .browser_download_url' <<<"$json")
    [ -n "$url" ] && [ "$url" != null ] || die "asset $name not found"
    curl -fsSL -o "$dest" "$url"
    digest=$(jq -r --arg n "$name" '.assets[] | select(.name==$n) | .digest // empty' <<<"$json")
    digest=${digest#sha256:}
    if [ -z "$digest" ]; then
        # fall back to the release's checksum file(s)
        local sumfile
        sumfile=$(jq -r --arg n "$name" '.assets[] | select(.name==($n+".sha256") or .name=="checksums.txt") | .browser_download_url' <<<"$json" | head -1)
        [ -n "$sumfile" ] || die "no checksum published for $name"
        digest=$(curl -fsSL "$sumfile" | awk -v n="$name" 'NF==1{print $1; exit} $2==n || $2=="*"n {print $1; exit}')
    fi
    [ -n "$digest" ] || die "could not read checksum for $name"
    echo "$digest  $dest" | sha256sum -c --quiet - || die "checksum mismatch for $name"
}

install_binaries() {
    say "Binaries into $BIN (verified with sha256)"
    [ "$(uname -m)" = x86_64 ] || { warn "only x86_64 assets are wired up; skipping binaries"; return; }
    command -v jq >/dev/null && command -v curl >/dev/null || die "jq and curl are needed (dnf install jq curl)"
    mkdir -p "$BIN"
    local tmp; tmp=$(mktemp -d); TMP_DIRS+=("$tmp")
    local json v

    if [ $UPDATE = 1 ] || ! command -v starship >/dev/null; then
        json=$(gh_release starship/starship)
        fetch_verified "$json" starship-x86_64-unknown-linux-musl.tar.gz "$tmp/st.tgz"
        tar -xzf "$tmp/st.tgz" -C "$tmp" && install -m755 "$tmp/starship" "$BIN/"
        ok "starship $(jq -r .tag_name <<<"$json")"
    else ok "starship already installed"; fi

    if [ $UPDATE = 1 ] || ! command -v lazygit >/dev/null; then
        json=$(gh_release jesseduffield/lazygit); v=$(jq -r .tag_name <<<"$json"); v=${v#v}
        fetch_verified "$json" "lazygit_${v}_linux_x86_64.tar.gz" "$tmp/lg.tgz"
        mkdir -p "$tmp/lg" && tar -xzf "$tmp/lg.tgz" -C "$tmp/lg" && install -m755 "$tmp/lg/lazygit" "$BIN/"
        ok "lazygit $v"
    else ok "lazygit already installed"; fi

    if [ $UPDATE = 1 ] || ! command -v lazydocker >/dev/null; then
        json=$(gh_release jesseduffield/lazydocker); v=$(jq -r .tag_name <<<"$json"); v=${v#v}
        fetch_verified "$json" "lazydocker_${v}_Linux_x86_64.tar.gz" "$tmp/lzd.tgz"
        mkdir -p "$tmp/lzd" && tar -xzf "$tmp/lzd.tgz" -C "$tmp/lzd" && install -m755 "$tmp/lzd/lazydocker" "$BIN/"
        ok "lazydocker $v"
    else ok "lazydocker already installed"; fi

    if [ $UPDATE = 1 ] || ! command -v yazi >/dev/null; then
        json=$(gh_release sxyazi/yazi)
        fetch_verified "$json" yazi-x86_64-unknown-linux-musl.zip "$tmp/yazi.zip"
        unzip -q "$tmp/yazi.zip" -d "$tmp/yz"
        install -m755 "$tmp"/yz/yazi-*/yazi "$tmp"/yz/yazi-*/ya "$BIN/"
        ok "yazi $(jq -r .tag_name <<<"$json")"
    else ok "yazi already installed"; fi

    if [ $UPDATE = 1 ] || [ ! -f "$HOME/.local/share/blesh/ble.sh" ]; then
        json=$(gh_release akinomyoga/ble.sh nightly)
        fetch_verified "$json" ble-nightly.tar.xz "$tmp/ble.txz"
        tar -xJf "$tmp/ble.txz" -C "$tmp"
        rm -rf "$HOME/.local/share/blesh" && mkdir -p "$HOME/.local/share"
        cp -a "$tmp/ble-nightly" "$HOME/.local/share/blesh"
        ok "ble.sh nightly"
    else ok "ble.sh already installed"; fi
}

# ── 3. Config links ─────────────────────────────────────────────────────
link() { # repo_path target
    local src="$DOTFILES/$1" dst=$2
    [ -e "$src" ] || die "missing in repo: $1"
    if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
        return 0
    fi
    mkdir -p "$(dirname "$dst")"
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        mkdir -p "$BACKUP/$(dirname "${dst#$HOME/}")"
        mv "$dst" "$BACKUP/${dst#$HOME/}"
        warn "backed up existing ${dst/#$HOME/\~}"
    fi
    ln -s "$src" "$dst"
    ok "${dst/#$HOME/\~}"
}

install_links() {
    say "Config links (→ $DOTFILES)"
    link home/.bashrc               "$HOME/.bashrc"
    link home/.bash_aliases         "$HOME/.bash_aliases"
    link home/.bash_functs          "$HOME/.bash_functs"
    link home/.bashrc.d/10-env.sh   "$HOME/.bashrc.d/10-env.sh"
    link home/.bashrc.d/20-tools.sh "$HOME/.bashrc.d/20-tools.sh"
    link bin/ai                     "$BIN/ai"
    link config/ghostty/config.ghostty "$HOME/.config/ghostty/config.ghostty"
    link config/ghostty/CHEATSHEET.md  "$HOME/.config/ghostty/CHEATSHEET.md"
    link config/tmux/tmux.conf      "$HOME/.config/tmux/tmux.conf"
    link config/starship.toml       "$HOME/.config/starship.toml"
    for f in config.yml theme-mocha.yml theme-latte.yml; do
        link "config/lazygit/$f" "$HOME/.config/lazygit/$f"
    done
    for f in yazi.toml theme.toml init.lua package.toml keymap.toml; do
        link "config/yazi/$f" "$HOME/.config/yazi/$f"
    done
    for f in "$DOTFILES"/config/btop/themes/*.theme; do
        link "config/btop/themes/$(basename "$f")" "$HOME/.config/btop/themes/$(basename "$f")"
    done
    link config/thefuck/settings.py "$HOME/.config/thefuck/settings.py"

    # btop rewrites its whole config on exit, so it is copied (once), not linked.
    if [ ! -e "$HOME/.config/btop/btop.conf" ]; then
        cp "$DOTFILES/config/btop/btop.conf" "$HOME/.config/btop/btop.conf"; ok "~/.config/btop/btop.conf (copied)"
    fi

    # git: pull in the delta settings without touching the rest of ~/.gitconfig
    local inc="$DOTFILES/git/delta.gitconfig"
    if ! git config --global --get-all include.path 2>/dev/null | grep -qxF "$inc"; then
        git config --global --add include.path "$inc"; ok "~/.gitconfig includes git/delta.gitconfig"
    fi
}

# ── 4. Plugins and caches ───────────────────────────────────────────────
install_plugins() {
    say "Plugins"
    local tpm="$HOME/.config/tmux/plugins/tpm"
    [ -d "$tpm" ] || git clone -q --depth 1 https://github.com/tmux-plugins/tpm "$tpm"
    "$tpm/bin/install_plugins" >/dev/null && ok "tmux plugins (TPM)"
    if command -v ya >/dev/null; then ya pkg install >/dev/null && ok "yazi plugins and flavors"; fi
    if command -v tldr >/dev/null; then tldr --update >/dev/null 2>&1 && ok "tldr pages"; fi
}

[ $DO_PACKAGES = 1 ] && install_packages
[ $DO_BINARIES = 1 ] && install_binaries
install_links
[ $DO_PLUGINS = 1 ] && install_plugins

say "Done"
[ -d "$BACKUP" ] && echo "  Previous files saved in ${BACKUP/#$HOME/\~}"
cat <<'EOF'
  Next:
    · open a new terminal (or `source ~/.bashrc`)
    · fully restart Ghostty (Ctrl+Shift+Q) so it loads its config
    · optional, for `ai`: install Ollama (https://ollama.com) and `ollama pull qwen2.5-coder:7b`
    · optional: `atuin import bash` to bring your old history into Ctrl+R
    · `cheat` shows every shortcut
EOF
