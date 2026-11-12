```
███████╗ ██╗   ██╗ ██████╗  ███████╗ ██████╗  ████████╗ ███████╗ ██████╗  ███╗   ███╗
██╔════╝ ██║   ██║ ██╔══██╗ ██╔════╝ ██╔══██╗ ╚══██╔══╝ ██╔════╝ ██╔══██╗ ████╗ ████║
███████╗ ██║   ██║ ██████╔╝ █████╗   ██████╔╝    ██║    █████╗   ██████╔╝ ██╔████╔██║
╚════██║ ██║   ██║ ██╔═══╝  ██╔══╝   ██╔══██╗    ██║    ██╔══╝   ██╔══██╗ ██║╚██╔╝██║
███████║ ╚██████╔╝ ██║      ███████╗ ██║  ██║    ██║    ███████╗ ██║  ██║ ██║ ╚═╝ ██║
╚══════╝  ╚═════╝  ╚═╝      ╚══════╝ ╚═╝  ╚═╝    ╚═╝    ╚══════╝ ╚═╝  ╚═╝ ╚═╝     ╚═╝
```

**superterm** — my terminal setup on Fedora: **Ghostty** + **bash** (ble.sh, starship, atuin, fzf, zoxide,
thefuck) + **tmux**, with lazygit, lazydocker, yazi, btop and a local-LLM `ai` command — all in
Catppuccin, following GNOME's light/dark mode.

## New machine

```bash
sudo dnf install -y git
git clone https://github.com/gonzaaalo17/superterm.git ~/Projects/superterm
cd ~/Projects/superterm
./install.sh
```

Then fully restart Ghostty (`Ctrl+Shift+Q`) and open a new terminal. `cheat` lists every shortcut.

`install.sh` does, in order:

1. **Packages** — Ghostty (COPR `scottames/ghostty`) and everything in `packages.txt`, with dnf,
   plus the weekly system update timer (see *Updates*).
2. **Binaries** not packaged in Fedora, into `~/.local/bin`: starship, lazygit, lazydocker, yazi
   and ble.sh — latest GitHub releases, each verified against its published sha256.
3. **Links** — every config in this repo is symlinked into place. Anything already there is moved
   to `~/.dotfiles-backup/<timestamp>/` first. `~/.gitconfig` only gets an `[include]` of
   `git/delta.gitconfig`; the rest of it (name, email, credentials) is left alone. The weekly
   user update timer is enabled here.
4. **Plugins** — tmux plugins (TPM), yazi plugins and flavors, tldr pages.

It is safe to run again. Options: `--links` (only the symlinks), `--no-packages`, `--update`
(re-download the binaries).

Optional extras, not automated:

- `ai` needs [Ollama](https://ollama.com) and a model: `ollama pull qwen2.5-coder:7b`.
- `atuin import bash` brings the old bash history into `Ctrl+R`.

## Day to day

The files in `~/.config/…` are links into this repo, so editing a config edits the repo:

```bash
cd ~/Projects/superterm
git status            # see what changed
git commit -am "…"    # save it
git push
```

On another machine: `git pull` (and `./install.sh --links` if a new file was added).

## Updates

Everything updates itself once a week, with two systemd timers (they run at the next boot or
login if the machine was off at that time):

| Timer | When | What |
|---|---|---|
| `weekly-update.timer` (system, root) | Mondays 10:00 | `dnf upgrade` and system flatpaks |
| `update-all.timer` (user) | Mondays 10:30 | user flatpaks, `uv` Pythons and tools, the GitHub binaries (`install.sh --update`), tmux and yazi plugins, tldr pages |

`update-all` runs the same by hand (system part included, with sudo); `update-all --user` only
the user part. A desktop notification appears if a step fails or a reboot is needed; nothing
reboots on its own.

```bash
systemctl list-timers weekly-update.timer; systemctl --user list-timers update-all.timer
journalctl -u weekly-update          # last system update
journalctl --user -u update-all      # last user update
```

`ya pkg upgrade` records the new plugin revisions in `config/yazi/package.toml`, so after an
update that file may show up in `git status`: commit it to keep the other machines in step.
Ollama is not included: it updates by rerunning its official installer.

## Layout

| Path | Goes to |
|---|---|
| `home/.bashrc`, `.bash_aliases`, `.bash_functs` | `~/` |
| `home/.bashrc.d/10-env.sh`, `20-tools.sh` | `~/.bashrc.d/` (environment, tool init) |
| `bin/ai`, `bin/update-all` | `~/.local/bin/` |
| `config/systemd/user/update-all.*` | `~/.config/systemd/user/` (weekly user updates) |
| `system/weekly-update.*` | copied to `/etc/systemd/system/` (weekly system update, as root) |
| `config/ghostty/` | `~/.config/ghostty/` (config + `CHEATSHEET.md` for `cheat`) |
| `config/tmux/tmux.conf` | `~/.config/tmux/` |
| `config/starship.toml` | `~/.config/` |
| `config/lazygit/`, `config/yazi/`, `config/thefuck/` | `~/.config/…` |
| `config/btop/` | themes linked; `btop.conf` copied once (btop rewrites it on exit) |
| `git/delta.gitconfig` | included from `~/.gitconfig` |
| `packages.txt` | dnf package list |

## Not in the repo, on purpose

Personal, per-machine extras go in `~/.bash_aliases.local` and `~/.config/ghostty/CHEATSHEET.local.md`:
both are loaded when present (by `~/.bash_aliases` and `cheat`) and never committed.

Secrets and per-machine state: atuin's key and history database, `gh` tokens, git credentials,
`~/.config/ai/config.json` (the chosen model), and anything the installer downloads (plugins,
binaries).
