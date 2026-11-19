# ── Environment ─────────────────────────────────────────────────────────

export EDITOR=nvim
export VISUAL=nvim

# Catppuccin flavor based on GNOME light/dark mode (same as Ghostty).
# Computed when each shell starts; used by bat, delta, fzf, starship and lazygit.
if [[ "$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null)" == *light* ]]; then
    export CATPPUCCIN_FLAVOR=latte
    export BAT_THEME="Catppuccin Latte"
else
    export CATPPUCCIN_FLAVOR=mocha
    export BAT_THEME="Catppuccin Mocha"
fi

# Colored man pages through bat
if command -v bat >/dev/null; then
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    export MANROFFOPT="-c"
fi

# History: large, no duplicates, shared across tabs
export HISTSIZE=100000
export HISTFILESIZE=200000
export HISTCONTROL=ignoreboth:erasedups
export HISTIGNORE="ls:ll:l:la:cd:pwd:exit:clear"
shopt -s histappend

# bash quality of life
shopt -s autocd      # type a directory name to cd into it
shopt -s cdspell     # fix small typos in cd
shopt -s dirspell
shopt -s globstar    # recursive **
shopt -s checkwinsize

# lazygit: base config + Catppuccin theme for the current mode
export LG_CONFIG_FILE="$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/theme-$CATPPUCCIN_FLAVOR.yml"

# opencode: local only. No model catalog download, update checks or unverified LSP downloads
# (Mason installs the LSPs), and Claude Code's global CLAUDE.md and skills are not its prompt.
export OPENCODE_DISABLE_MODELS_FETCH=1
export OPENCODE_DISABLE_AUTOUPDATE=1
export OPENCODE_DISABLE_LSP_DOWNLOAD=1
export OPENCODE_DISABLE_CLAUDE_CODE_PROMPT=1
export OPENCODE_DISABLE_CLAUDE_CODE_SKILLS=1
