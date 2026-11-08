# ~/.bash_aliases — all aliases in one place
# Sourced from ~/.bashrc. Optional tools are checked with `command -v`.

_has() { command -v "$1" >/dev/null 2>&1; }

# ── File listing ────────────────────────────────────────────────────────
# ll is a function in ~/.bash_functs (eza icons, same ordering as rmgroup).
# Fedora's /etc/profile.d defines `alias ll`, which would shadow the function.
unalias ll 2>/dev/null
alias lls='LC_ALL=C ls -lah --group-directories-first'   # the classic ll
if _has eza; then
    alias l='eza -l --icons --git --group-directories-first'
    alias la='eza -la --icons --git --group-directories-first'
    alias lt='eza --tree --level=2 --icons --git-ignore'
    alias lta='eza --tree --level=3 --icons -a --ignore-glob=.git'
else
    alias l='ls -lh --group-directories-first'
    alias la='ls -lah --group-directories-first'
fi

# ── Navigation ──────────────────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

# ── Modern replacements ─────────────────────────────────────────────────
# cat is a function in ~/.bash_functs (Markdown rendered with glow, the rest with bat)
unalias cat 2>/dev/null
_has btop   && alias top='btop'
# dust and duf are used by name (not aliased over du/df: their flags differ,
# so `du -sh` / `df -h` from muscle memory would just print help)
_has trash-put && alias tp='trash-put'   # move to trash instead of deleting
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip -color=auto'

# ── TUI apps ────────────────────────────────────────────────────────────
alias lg='lazygit'
alias lzd='lazydocker'
alias v='nvim'
alias t='tmux new-session -A -s main'    # enter (or return to) the main session

# ── Git ─────────────────────────────────────────────────────────────────
alias g='git'
alias gst='git status -sb'   # not `gs`: that is Ghostscript
alias gd='git diff'
alias gds='git diff --staged'
alias glog='git log --graph --pretty=format:"%C(yellow)%h%Creset %C(blue)%ad%Creset %s%C(red)%d%Creset %C(dim)%an%Creset" --date=short'

# ── System ──────────────────────────────────────────────────────────────
alias reload='source ~/.bashrc && echo "bashrc reloaded"'
alias path='tr ":" "\n" <<< "$PATH"'
alias ports='ss -tulpn'
alias update='sudo dnf upgrade --refresh && flatpak update'

# ── This machine only ───────────────────────────────────────────────────
# Personal aliases live in ~/.bash_aliases.local, which is not in the repo.
[ -f ~/.bash_aliases.local ] && . ~/.bash_aliases.local

unset -f _has
