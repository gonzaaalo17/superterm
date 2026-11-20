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
4. **Plugins** — tmux plugins (TPM), yazi plugins and flavors, Neovim plugins (the versions in
   `lazy-lock.json`) and its Spanish spell dictionary, tldr pages.

It is safe to run again. Options: `--links` (only the symlinks), `--no-packages`, `--update`
(re-download the binaries; latest Neovim plugins, parsers and Mason tools).

Optional extras, not automated:

- Local AI (`ai`, Neovim, opencode) needs [Ollama](https://ollama.com) and two models:
  `ollama pull qwen3.6:35b-a3b-coding` (agents, chat, `ai`) and `ollama pull qwen2.5-coder:1.5b-base`
  (completion). Then run `./install.sh` again: it creates `qwen3.6-128k`, the same model with a 128k
  context (`config/ollama/`).
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

## Workspace: `dev`

`dev` opens a project as a tmux session, or goes back to it if it is already open. One window,
`code`, with everything in view:

```
┌──────────────────────┬──────────────┐
│ nvim                 │ opencode     │   opencode on the project's last
│                      │ (40 %)       │   conversation (--continue)
├──────────────────────┤              │
│ shell (25 %)         │              │
└──────────────────────┴──────────────┘
```

`Ctrl+h/j/k/l` moves between the three (from nvim too); `prefix z` makes the current pane full
screen and back, `prefix H/J/K/L` resizes.

- **Project:** the directory given (`dev ~/Projects/foo`) or the current one; inside a git repo, the
  repo's root, so `dev` from any subfolder lands in the same session. In `~` it offers the folders
  of `~/Projects` (fzf); `/` is refused. The session is named after the folder (`parent-folder` if
  another project already has that name).
- **Leaving** (closing Ghostty, `prefix d`) keeps everything running, unsaved buffers and the
  agent's work included; `dev` there brings it back as it was. `dev -k` closes it (the current
  one inside a workspace). Open sessions cost RAM (nvim, its LSPs, opencode), almost no CPU; the
  GPU model is Ollama's, unloaded after a few idle minutes whatever is open.
- **Closing is for good:** `dev -k`, `tmux kill-server` or a reboot end the session, and nothing
  brings it back on its own (tmux sessions are not saved or restored). `dev` starts it again:
  opencode resumes the project's last conversation (it keeps them on disk) and `Space qs` in nvim
  reopens the files you had. Unsaved changes and running servers are gone.
- **The agent full screen:** `prefix a` goes to opencode and zooms it; `prefix a` again brings the
  layout back and returns to the pane you were in. Outside a workspace it opens opencode on the
  right of the window. Going back to nvim reloads the files the agent changed (focus events).
- **nvim → agent:** `Space ao` types `@file` (with `lines a-b` on a selection) into opencode's
  prompt and moves to it; the file is saved first, since the agent reads it from disk.
- **agent → nvim:** when you say "this file", "the selection", "these errors", opencode runs
  `nvim-context` (allowed without asking): it asks this session's nvim, through its server socket,
  for the current file, cursor, last selection, diagnostics and unsaved buffers.

**opencode** (`config/opencode/`, installed by `install.sh`, checksum-verified): local only. Only the
Ollama provider is enabled (`qwen3.6-128k`); sharing, update checks, the models.dev catalog, LSP
downloads and Claude Code's `~/.claude` files are off (`home/.bashrc.d/10-env.sh`). It asks before
every edit (diff), every command but `git status/diff/log`, `ls` and `nvim-context`, and anything
outside the project. Its rules, shared with the nvim chat, are `config/agents/AGENTS.md`: read-only
until asked, a plan and your confirmation before any change, the git rules, and answers in the
language you write in. The local model does not always present the plan first; the permission
prompts are the real gate. Theme `superterm`: Catppuccin on the terminal's own background.
`update-all` checks each new opencode release against this config before installing it; if it
no longer applies (a renamed or dropped setting), the release is not installed and a desktop
notification says so, so the config can be adapted first.

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
  `Space ap` actions, `Space ac` send the selection to the chat. Answers in the language you write
  in; it reads the agents' global rules (`config/agents/AGENTS.md`) and the project's rule files
  (`AGENTS.md`, `CLAUDE.md`…), not `~/.claude/CLAUDE.md`.
- Agent mode: start a chat message with `@{agent}` and it reads and searches the project (no
  prompts inside it, a prompt for anything outside), edits files (each edit shown as a diff to
  accept) and runs commands (always asks). It needs a model with tool calling (the default
  `qwen3.6-128k`). If a local model stops halfway through a task, "continúa" picks it up.
- Each has its own model, per machine, in `~/.config/ai/config.json` (the `ai` command's file,
  not committed): `"nvim": {"complete": "…", "chat": "…", "chat_ctx": 131072}`. `Space am` /
  `:AIModel` picks them from the installed models; completion switches at once, chat from the next
  conversation. On a machine with more VRAM, just point them at bigger models.

Defaults, measured on an 8 GB RTX 5060: completion `qwen2.5-coder:1.5b-base` (~300 ms); chat
`qwen3.6-128k` (~43 tok/s, 91% on the GPU), the best of four agent models in a benchmark (10/10
tasks, no broken tool calls). Both stay loaded together, so going from typing to chat costs no
reload, and opencode and `ai` share the chat model's loaded copy. `chat_ctx` must stay at the
model's 131072: another value makes Ollama load a second copy.

**Adding a language:** `:LazyExtras`, pick `lang.<name>`, press `x`, restart. It brings the LSP,
formatter, linter, treesitter parser and debugger, and is recorded in `lazyvim.json` — commit it.
**Your own plugins:** a new file in `lua/plugins/` returning a lazy.nvim spec.
**Spelling:** English and Spanish (`spelllang=en,es`), on in markdown, text and git commits as
LazyVim sets it; `Space us` toggles it elsewhere. `install.sh` downloads the Spanish dictionary
(Vim's own, pinned by sha256) into `~/.local/share/nvim/site/spell`.
**Updating:** Neovim itself comes from dnf. Plugins, treesitter parsers and Mason tools (LSPs,
formatters, linters) update every Monday with `update-all` (`install.sh --update`), or by hand with
`:Lazy update` and `:Mason`. After a successful update the new `lazy-lock.json` is committed on its
own ("nvim: update plugins", listing them), never pushed: push when you want other machines to get
the same versions. If an update breaks something, `git revert` that commit and run `:Lazy restore`.
LSPs and tools are installed by Mason on first launch (`:Mason` to see them).

## Updates

Everything updates itself once a week, with two systemd timers (they run at the next boot or
login if the machine was off at that time):

| Timer | When | What |
|---|---|---|
| `weekly-update.timer` (system, root) | Mondays 10:00 | `dnf upgrade`, system flatpaks and Ollama (`update-ollama`) |
| `update-all.timer` (user) | Mondays 10:30 | user flatpaks, `uv` Pythons and tools, the GitHub binaries (`install.sh --update`), Neovim plugins, parsers and Mason tools, tmux and yazi plugins, tldr pages |

`update-all` runs the same by hand (system part included, with sudo); `update-all --user` only
the user part. Run by hand it also copies the root-owned files in `system/` (the timer units and
`update-ollama`) when they differ from the repo, so a fix to them reaches the weekly timer; the
timers alone never do that (`./install.sh --system-files` does just that step). A desktop notification appears if a step fails or a reboot is needed; nothing
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
| `home/.bashrc`, `.bash_aliases`, `.bash_functs`, `.blerc` (ble.sh) | `~/` |
| `home/.bashrc.d/10-env.sh`, `20-tools.sh` | `~/.bashrc.d/` (environment, tool init) |
| `bin/ai`, `bin/update-all`, `bin/dev`, `bin/nvim-context` | `~/.local/bin/` |
| `config/systemd/user/update-all.*` | `~/.config/systemd/user/` (weekly user updates) |
| `system/weekly-update.*` | copied to `/etc/systemd/system/` (weekly system update, as root) |
| `system/update-ollama` | copied to `/usr/local/sbin/` (run by the system update) |
| `config/ghostty/` | `~/.config/ghostty/` (config + `CHEATSHEET.md` for `cheat`) |
| `config/tmux/tmux.conf` | `~/.config/tmux/` |
| `config/nvim/` | `~/.config/nvim` (whole directory) |
| `config/opencode/`, `config/agents/AGENTS.md` | `~/.config/opencode/` (config, theme, the agents' rules) |
| `config/ollama/` | Modelfiles `install.sh` creates in Ollama (`qwen3.6-128k`) |
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
