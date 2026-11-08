# ── Tool initialization ─────────────────────────────────────────────────
# Each tool loads only if installed, so the shell never breaks.

[[ $- == *i* ]] || return 0

# fzf: Ctrl+T files · Alt+C directories · ** + Tab fuzzy completion
if command -v fzf >/dev/null; then
    if command -v fd >/dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    fi
    if [[ $CATPPUCCIN_FLAVOR == latte ]]; then
        _fzf_colors='--color=bg+:#CCD0DA,spinner:#DC8A78,hl:#D20F39,fg:#4C4F69,header:#D20F39,info:#8839EF,pointer:#DC8A78,marker:#7287FD,fg+:#4C4F69,prompt:#8839EF,hl+:#D20F39,selected-bg:#BCC0CC,border:#9CA0B0,label:#4C4F69'
    else
        _fzf_colors='--color=bg+:#313244,spinner:#F5E0DC,hl:#F38BA8,fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC,marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8,selected-bg:#45475A,border:#6C7086,label:#CDD6F4'
    fi
    export FZF_DEFAULT_OPTS="--height=50% --layout=reverse --border=rounded --info=inline-right --marker='+' $_fzf_colors"
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:300 {} 2>/dev/null || ls -la {}'"
    export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --icons --color=always {} 2>/dev/null || ls {}'"
    unset _fzf_colors
    eval "$(fzf --bash)"
fi

# zoxide: `z project` jumps to the most used match · `zi` picks with fzf
command -v zoxide >/dev/null && eval "$(zoxide init bash)"

# direnv: loads .envrc when entering a directory
command -v direnv >/dev/null && eval "$(direnv hook bash)"

# atuin: Ctrl+R searchable history (after fzf so it keeps Ctrl+R)
command -v atuin >/dev/null && eval "$(atuin init bash --disable-up-arrow)"

# starship: prompt. In light mode it uses a copy with the Latte palette.
if command -v starship >/dev/null; then
    if [[ $CATPPUCCIN_FLAVOR == latte ]]; then
        _sc=~/.config/starship.toml _sl=~/.cache/starship-latte.toml
        if [[ ! -f $_sl || $_sc -nt $_sl ]]; then
            mkdir -p ~/.cache && sed 's/^palette = "catppuccin_mocha"/palette = "catppuccin_latte"/' "$_sc" > "$_sl"
        fi
        export STARSHIP_CONFIG=$_sl
        unset _sc _sl
    fi
    eval "$(starship init bash)"
fi

# thefuck / pay-respects: type `fuck` after a failed command to fix it.
# Loaded lazily on first use, so it does not slow down every new shell.
if command -v thefuck >/dev/null; then
    fuck() { unset -f fuck; eval "$(thefuck --alias)"; fuck "$@"; }
elif command -v pay-respects >/dev/null; then
    eval "$(pay-respects bash --alias fuck)"
fi
