```
███████╗ ██╗   ██╗ ██████╗  ███████╗ ██████╗  ████████╗ ███████╗ ██████╗  ███╗   ███╗
██╔════╝ ██║   ██║ ██╔══██╗ ██╔════╝ ██╔══██╗ ╚══██╔══╝ ██╔════╝ ██╔══██╗ ████╗ ████║
███████╗ ██║   ██║ ██████╔╝ █████╗   ██████╔╝    ██║    █████╗   ██████╔╝ ██╔████╔██║
╚════██║ ██║   ██║ ██╔═══╝  ██╔══╝   ██╔══██╗    ██║    ██╔══╝   ██╔══██╗ ██║╚██╔╝██║
███████║ ╚██████╔╝ ██║      ███████╗ ██║  ██║    ██║    ███████╗ ██║  ██║ ██║ ╚═╝ ██║
╚══════╝  ╚═════╝  ╚═╝      ╚══════╝ ╚═╝  ╚═╝    ╚═╝    ╚══════╝ ╚═╝  ╚═╝ ╚═╝     ╚═╝
```

**superterm** — my terminal setup on Fedora: **Ghostty** + **bash** (ble.sh, starship, atuin, fzf, zoxide,
thefuck) + **tmux** + **Neovim** (as a full IDE, on LazyVim), with lazygit, lazydocker, lazysql, yazi, btop and a local-LLM `ai` command — all in
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
2. **Binaries** not packaged in Fedora, into `~/.local/bin`: starship, lazygit, lazydocker, lazysql, yazi
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
- AI in Neovim needs `ollama pull qwen2.5-coder:1.5b-base` (completion) and `ollama pull qwen2.5-coder:14b` (chat), or whatever `:AIModel` is set to.
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

## Neovim

`config/nvim/` is a Neovim config built on [LazyVim](https://www.lazyvim.org): LazyVim's defaults
and keymaps apply as documented, so any LazyVim guide works as is. On top of it:

| File | What |
|---|---|
| `lua/config/options.lua` | differences from LazyVim's options; light/dark from GNOME |
| `lua/config/keymaps.lua` | extra keys LazyVim leaves free: `U` redo, `ñ` toggle case, `´` search word, arrows move between windows, `Enter`/`Alt+Enter` blank lines below/above |
| `lua/config/commands.lua` | `:Bufrando` (run normal keys or an Ex command on a set of buffers) |
| `lua/plugins/colorscheme.lua` | Catppuccin Mocha/Latte, transparent background (Ghostty's opacity shows through) |
| `lua/plugins/tmux.lua` | `Ctrl+h/j/k/l` crosses between nvim windows and tmux panes |
| `lazyvim.json` | enabled LazyVim extras (languages, debugger, tests) |
| `lazy-lock.json` | exact plugin versions, restored by `install.sh` |
| `lua/plugins/project-tools.lua`, `lua/tools/project.lua` | lazygit / lazydocker / lazysql / dadbod on the current project |
| `lua/plugins/ai.lua`, `lua/tools/ai.lua` | local AI: inline completion and chat, models per machine |

**Global vs project.** In the shell lazygit, lazydocker and lazysql work as always (global). Inside
Neovim they open on the current project, its git root:

- `Space gg` lazygit. Edits made from it open in the same Neovim, and it keeps superterm's theme.
- `Space od` lazydocker on the compose project(s) whose containers were started from inside the
  project (read from the containers' compose labels; a picker if there are several, e.g. a
  sandbox stack next to the main one). Standalone containers, images, volumes and networks stay
  global: lazydocker cannot filter those. `Space oD` is the global view.
- `Space os` lazysql on the project's databases: `.lazysql.toml` in the root (lazysql's own
  format) or else every `*DATABASE_URL` / `*DB_URL` in `.env` / `.env.local`. The connections go
  through a private temporary file, never the command line. `Space oS` is the global list.
- `Space D` dadbod-ui with the same `.env` connections.

URLs that use a compose service name as host (`db:5432`) only resolve inside the compose network;
from the host, use what the port is published on (`localhost`). Keep `.lazysql.toml` out of git if
it holds passwords. lazysql is always run with `-no-telemetry`, also via the shell alias.

**Local AI** (`lua/plugins/ai.lua`, `lua/tools/ai.lua`), all through Ollama, nothing leaves the machine:

- Inline completion while typing (minuet-ai): grey text, `Tab` accepts, `Alt+a` one line,
  `Alt+]`/`Alt+[` next/previous, `Alt+e` dismiss, `Space at` toggles it in the buffer.
- Chat and inline edits (CodeCompanion): `Space aa` chat, `Space ai` inline (also on a selection),
  `Space ap` actions, `Space ac` send the selection to the chat. Answers in Spanish; it reads the
  project's rule files (`AGENTS.md`, `CLAUDE.md`…), not `~/.claude/CLAUDE.md`.
- Each has its own model, per machine, in `~/.config/ai/config.json` (the `ai` command's file,
  not committed): `"nvim": {"complete": "…", "chat": "…", "chat_ctx": 16384}`. `Space am` /
  `:AIModel` picks them from the installed models; completion switches at once, chat from the next
  conversation. On a machine with more VRAM, just point them at bigger models.

Defaults, measured on an 8 GB RTX 5060: completion `qwen2.5-coder:1.5b-base` (~300 ms, always on
the GPU); chat `qwen2.5-coder:14b` (~11 tok/s, partly on CPU). The 14b does not fit next to the
completion model, so going from chat to typing (or back) reloads one of them, ~4-5 s the first
time. `qwen2.5-coder:7b` as chat model runs at ~74 tok/s and fits next to it: no reloads.

**Adding a language:** `:LazyExtras`, pick `lang.<name>`, press `x`, restart. It brings the LSP,
formatter, linter, treesitter parser and debugger, and is recorded in `lazyvim.json` — commit it.
**Your own plugins:** a new file in `lua/plugins/` returning a lazy.nvim spec.
**Updating plugins:** `:Lazy update`, then commit `lazy-lock.json` so other machines get the same versions.
LSPs and tools are installed by Mason on first launch (`:Mason` to see them).

## Updates

Everything updates itself once a week, with two systemd timers (they run at the next boot or
login if the machine was off at that time):

| Timer | When | What |
|---|---|---|
| `weekly-update.timer` (system, root) | Mondays 10:00 | `dnf upgrade`, system flatpaks and Ollama (`update-ollama`) |
| `update-all.timer` (user) | Mondays 10:30 | user flatpaks, `uv` Pythons and tools, the GitHub binaries (`install.sh --update`), tmux and yazi plugins, tldr pages |

`update-all` runs the same by hand (system part included, with sudo); `update-all --user` only
the user part. A desktop notification appears if a step fails or a reboot is needed; nothing
reboots on its own.

It also warns about orphaned packages: installed, but no enabled repo offers them any more, so
`dnf upgrade` silently stops updating them and they can block a Fedora release upgrade (this
happened when Fedora renamed `nodejs` to `nodejs22`). For each one it names the repo package
that now provides it and prints the `dnf do` command that swaps them; run by hand, `update-all`
offers to run it (dnf still shows the transaction and asks). The timer only notifies: it never
removes packages unattended. Locally built kernel modules (`kmod-*`, from akmods) are ignored.

```bash
systemctl list-timers weekly-update.timer; systemctl --user list-timers update-all.timer
journalctl -u weekly-update          # last system update
journalctl --user -u update-all      # last user update
```

`ya pkg upgrade` records the new plugin revisions in `config/yazi/package.toml`, so after an
update that file may show up in `git status`: commit it to keep the other machines in step.
Ollama is updated by `system/update-ollama` (copied to `/usr/local/sbin/`): same layout as the
official installer, but it only acts when there is a newer release, checks its sha256 first, and
restores the previous version if the new one does not start. If a root run fails, the next user
run raises the notification.

## Installing new tools

Take the first row that fits. Rows 1–5 are covered by the weekly updates; anything installed any
other way is never updated by anyone.

| # | What | How | Where it lands |
|---|---|---|---|
| 1 | Anything packaged in Fedora | `sudo dnf install X` — and add it to `packages.txt` | `/usr` |
| 2 | Desktop apps | Flatpak (Flathub) | sandboxed |
| 3 | Python CLIs | `uv tool install X` | `~/.local/share/uv/tools`, command in `~/.local/bin` |
| 4 | JavaScript CLIs | `npm i -g X` (npm's prefix is `~/.local`: no sudo) | `~/.local` |
| 5 | Binaries only published on GitHub | a block in `install.sh`, like lazygit (checksum-verified) | `~/.local/bin` |
| 6 | Databases and services (Postgres, Redis…) | a container (`docker` / `podman`), never on the host | the container |
| 7 | Experiments, odd dependencies | `toolbox create`, install inside, throw away | the container |

Project dependencies stay inside the project: `uv add X` (its `.venv`; a `.python-version` makes
uv fetch that Python on its own) and `npm install X` (its `node_modules`). One-off runs need no
install at all: `uvx tool`, `npx tool`.

New languages: Go and Java from dnf (`golang`, `java-XX-openjdk-devel`); Rust with rustup (then
add `rustup update` to `update-all`). Several versions of the same language at once is when a
version manager like mise starts to pay off.

Never: `sudo pip`, `pip install --user`, `sudo npm i -g`, tarballs unpacked by hand into `/opt`
or `/usr/local` (Ollama is the one exception, handled by `update-ollama`), `curl … | sh` as
root without reading it, or hand-added `PATH` lines in `.bashrc`.

## Layout

| Path | Goes to |
|---|---|
| `home/.bashrc`, `.bash_aliases`, `.bash_functs` | `~/` |
| `home/.bashrc.d/10-env.sh`, `20-tools.sh` | `~/.bashrc.d/` (environment, tool init) |
| `bin/ai`, `bin/update-all` | `~/.local/bin/` |
| `config/systemd/user/update-all.*` | `~/.config/systemd/user/` (weekly user updates) |
| `system/weekly-update.*` | copied to `/etc/systemd/system/` (weekly system update, as root) |
| `system/update-ollama` | copied to `/usr/local/sbin/` (run by the system update) |
| `config/ghostty/` | `~/.config/ghostty/` (config + `CHEATSHEET.md` for `cheat`) |
| `config/tmux/tmux.conf` | `~/.config/tmux/` |
| `config/nvim/` | `~/.config/nvim` (whole directory) |
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
