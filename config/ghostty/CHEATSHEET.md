# Terminal cheatsheet

## Ghostty

### Copy, paste, config
| Key | Action |
|---|---|
| `Ctrl+C` | Copy if text is selected; otherwise interrupt the program (as always) |
| `Ctrl+Shift+V` | Paste |
| `Ctrl+Shift+C` | Copy (always works) |
| `Ctrl+V` | Goes to the program: pastes an image in Claude Code, visual block in nvim |
| `Ctrl+Shift+A` | Select all |
| `Ctrl+Shift+,` | Reload config |
| `Ctrl+Shift+P` | Command palette (every action, searchable) |
| `Ctrl+Shift+I` | Inspector |

> Inside tmux, mouse drag is tmux's selection: it copies to the clipboard on release,
> then `Ctrl+Shift+V` pastes. Hold `Shift` while dragging for a Ghostty selection instead.

### Windows
| Key | Action |
|---|---|
| `Ctrl+Shift+N` | New window |
| `F11` | Fullscreen |
| `Ctrl+Shift+Q` | Quit Ghostty |

### Tabs
| Key | Action |
|---|---|
| `Ctrl+Shift+T` | New tab |
| `Ctrl+Shift+W` | Close tab |
| `Alt+1..8` / `Alt+9` | Go to tab N / last tab |
| `Ctrl+Tab` / `Ctrl+Shift+Tab` | Next / previous tab |
| `Ctrl+PgDn` / `Ctrl+PgUp` | Next / previous tab |
| `Ctrl+Shift+←` / `→` | Previous / next tab |
| `Ctrl+Shift+PgUp` / `PgDn` | Move tab left / right |

### Splits (Ghostty's own; tmux has its own below — use one or the other)
| Key | Action |
|---|---|
| `Ctrl+Shift+O` | Split right |
| `Ctrl+Shift+D` (or `E`) | Split down |
| `Ctrl+Alt+H/J/K/L` | Move to the split left / down / up / right |
| `Super+Ctrl+[` / `]` | Previous / next split |
| `Super+Ctrl+Shift+arrows` | Resize split |
| `Ctrl+Shift+=` | Make all splits equal |
| `Ctrl+Shift+Z` (or `Enter`) | Zoom the split (toggle) |
| `Ctrl+Shift+X` | Close the split |

> `Ctrl+Alt+arrows` are GNOME's workspace switching, which is why splits use H/J/K/L.

### Font, scrollback, prompts
| Key | Action |
|---|---|
| `Ctrl+=` / `Ctrl+-` / `Ctrl+0` | Font bigger / smaller / reset |
| `Ctrl+Shift+↑` / `↓` | Jump to previous / next prompt |
| `Ctrl+Shift+F` | Search scrollback |
| `Ctrl+Shift+S` | Open the whole scrollback in the editor |
| `Ctrl+Shift+J` | Paste the scrollback as a file path |
| `Ctrl+click` | Open URL |

## tmux · prefix `Ctrl+Space`
| Key | Action |
|---|---|
| `t` (shell alias) | Enter or return to the `main` session |
| `prefix \|` / `prefix -` | Vertical / horizontal split |
| `Ctrl+h/j/k/l` | Move between panes (and nvim) |
| `prefix H/J/K/L` | Resize pane |
| `prefix z` | Zoom pane (toggle) |
| `prefix x` | Close pane |
| `prefix c` | New window |
| `prefix 1..9` | Go to window N |
| `prefix n` / `p` | Next / previous window |
| `prefix w` | Window and session tree |
| `prefix <` / `>` | Move window left / right |
| `prefix ,` | Rename window |
| `prefix d` | Detach (session keeps running) |
| `prefix s` / `S` | Session tree / jump with fzf |
| `prefix g` | Popup: lazygit |
| `prefix y` | Popup: yazi |
| `prefix D` | Popup: lazydocker |
| `prefix b` | Popup: btop |
| `prefix j` | Popup: lazyjournal (logs) |
| `prefix t` | Popup: floating shell |
| `prefix u` | Open a URL from the screen (fzf) |
| `prefix [` | Copy mode (`v` select, `y` copy, `q` quit) |
| `prefix Ctrl+l` | Clear screen (`Ctrl+l` moves between panes) |
| `prefix Ctrl+k` | Delete to end of line (`Ctrl+k` moves between panes) |
| `prefix r` | Reload tmux.conf |
| `prefix I` / `U` | Install / update plugins |
| `prefix a` | The project's agent (opencode) full screen / back |

## Workspace · `dev`
| Command / key | What it does |
|---|---|
| `dev` · `dev <dir>` | Open the project (current dir / given; git root) or go back to it: nvim · shell below · opencode right |
| `dev` in `~` | Pick a project of ~/Projects (fzf) |
| `dev -k` · `dev -k <dir>` | Close the workspace for good (current / of that dir); `dev` starts it again |
| `Space qs` (nvim) | Reopen the files of the last nvim session in this project |
| `Ctrl+h/j/k/l` | Move between nvim, shell and opencode (nvim reloads files the agent changed) |
| `prefix a` · `prefix z` | opencode full screen and back · any pane full screen and back |
| `Space ao` (nvim) | Send the file / selected lines to opencode (`@file lines a-b`) and go to it |
| "este archivo", "lo seleccionado"… | opencode runs `nvim-context`: your file, cursor, selection, errors, unsaved buffers |
| `Tab` (opencode) · `ctrl+x m` · `ctrl+p` | Switch agent (build / plan) · model · command palette |

## Shell (bash + ble.sh)
| Key | Action |
|---|---|
| `→` or `Ctrl+F` | Accept the grey autosuggestion |
| `Alt+F` | Accept one word of the suggestion |
| `Ctrl+R` | Searchable history (atuin) |
| `Ctrl+T` | Find a file and paste it on the line (fzf) |
| `Alt+C` | Find a directory and cd into it (fzf) |
| `cd **<Tab>` | Fuzzy completion (works with any command) |
| `z text` / `zi` | Jump to a frequent directory / pick it with fzf |
| `fuck` | Fix the last failed command (thefuck): `Enter` runs the fix, `↑`/`↓` other options, `Ctrl+C` cancels |

## Prompt
```
  ~/Projects/myapp   dev ⇡4 !2 +1 ?1  +12 -3   took 4s
❯
```
| Symbol | Meaning |
|---|---|
| `⇡N` / `⇣N` | N commits to push / to pull |
| `⇕⇡A⇣B` | Diverged from the remote (A ahead, B behind) |
| `+N` | N files staged |
| `!N` | N files modified, not staged |
| `?N` | N untracked files |
| `✘N` / `»N` | N deleted / renamed |
| `≡N` | N stashes |
| `=N` | N files with conflicts |
| `+A -D` (green/red) | Lines added / removed, not yet committed |
| `(REBASING 1/3)` | Rebase, merge or cherry-pick in progress |
| `took 4s` | Last command took longer than 2 s |
| ` 1` | Last command's exit code (when it failed) |
| `❯` green / red | Last command succeeded / failed |

## Neovim (LazyVim) · leader `Space`
LazyVim's own keys apply as documented (https://www.lazyvim.org/keymaps). Press `Space` and wait: which-key lists the rest.

| Key | What it does |
|---|---|
| `Space Space` / `Space /` | Find file / grep in the project |
| `Space e` | File explorer |
| `Space fp` / `Space fz` | Open a project: git repos in ~/Projects + recent / any folder zoxide knows |
| `Space bd` / `Space wd` | Close the buffer (the window stays) / close the window (the split) |
| `Ctrl+w o` | Keep only the current window |
| `Space gg` | lazygit on the project (`e` on a file opens it in this nvim) |
| `Space od` / `Space oD` | lazydocker: this project's compose stack / everything |
| `Space os` / `Space oS` | lazysql: this project's databases / the global connections |
| `Space D` | dadbod-ui: SQL editor with table completion, project databases |
| `Space l` / `:LazyExtras` | Plugins / add a language (`x` to enable) |
| `Tab` · `Alt+a` · `Alt+]`/`Alt+[` · `Alt+e` | AI suggestion: accept · one line · next/prev · dismiss |
| `Space aa` / `Space ai` / `Space ap` | Local AI chat / inline edit / actions |
| `Space ao` | Send the file / selection to the agent (opencode) and go to it |
| `Space am` · `Space at` | Pick AI models (completion, chat) · toggle completion |
| `@{agent}` in the chat | Agent mode: reads, searches, edits (diff to accept) and runs commands (asks first) |
| `Ctrl+h/j/k/l` · arrows | Move between windows (Ctrl crosses into tmux panes) |
| `Ctrl+ñ` (or `Ctrl+/`) | Terminal in the project: open / hide |
| `z=` · `]s`/`[s` · `zg` | Spelling (English + Spanish, in markdown/text/commits): fix · next/prev · add word |
| `U` · `ñ` · `´` | Redo · toggle case · search word under cursor |
| `Enter` / `Alt+Enter` | Blank line(s) below / above |

Project databases come from `.lazysql.toml` in the project root (lazysql's format) or, if absent,
every `*DATABASE_URL` / `*DB_URL` in `.env` / `.env.local`.

## ai — local LLM (Ollama, nothing leaves the machine)
| Command | What it does |
|---|---|
| `ai "question"` | Ask anything (answers in the language you write in) |
| `ai --explain "tar -xzf f.tgz"` | Explain a command, each flag, with examples |
| `cmd \| ai --explain` | Explain an output, error or log |
| `cmd 2>&1 \| ai --explain "why"` | …focusing on a question |
| `cmd \| ai "question"` | Ask about piped output (e.g. `git diff \| ai "write a commit message"`) |
| `ai --models` | List local models (`*` = active) |
| `ai --switch` | Pick the default model with fzf |
| `ai --switch qwen2.5-coder:7b` | Set the default model directly |
| `ai -m phi3:mini "question"` | Use another model just this once |
| `ai --help` | Help |

> The first call after a while takes longer: Ollama has to load the model into memory.
> Default: `qwen3.6-128k`, the same model as the agents (opencode, nvim chat): one loaded copy for all.

## Commands and aliases
| Command | What it does |
|---|---|
| `cat file` | On screen: Markdown rendered (glow), other files coloured (bat). Piped or redirected: plain cat |
| `ll [dir]` | Long listing with icons and git status, in rmgroup's order (row N = index N-1) |
| `lls` | The classic `ls -lah` listing |
| `l` / `la` / `lt` | eza listing / with hidden files / tree |
| `y` | yazi; on quit leaves you in that directory |
| `fe [text]` | Find a file with fzf and open it in nvim |
| `rgf PATTERN` | Search text with ripgrep and open the match at that line |
| `fkill [signal]` | Pick processes with fzf and kill them |
| `mkcd dir` | Create a directory and cd into it |
| `extract file` | Unpack any archive format |
| `mvall` / `cpall` / `rmgroup` | Your existing functions |
| `lg` / `lzd` / `lsql` | lazygit / lazydocker / lazysql (telemetry off) |
| `lj` | lazyjournal: logs of services (system and user), kernel, /var/log, containers |
| `top` | btop |
| `dust [dir]` | Disk usage as a visual tree (`dust -d 2`, `dust -n 20`); `du` is still plain du |
| `duf` | Free space per disk, as a table; `df` is still plain df |
| `tp file` | Move to trash instead of deleting |
| `tldr command` | Quick usage examples (`tldr tar`, `tldr --update` to refresh) |
| `gst` · `gd` · `gds` · `glog` | git status / diff / staged diff / graph log |
| `..` · `...` · `....` · `-` | Up one / two / three directories · back to the previous one |
| `g` · `path` · `ports` | git · PATH one entry per line · listening ports |
| `update` | Quick dnf + flatpak upgrade (`update-all` is the full one) |
| `reload` | Reload bashrc |
| `cheat` | This cheatsheet |

## Installed tools
One line each so you remember they exist. Details: `tldr NAME` · `NAME --help` · `ai --explain "NAME …"`.

### Files and search
| Tool | What for |
|---|---|
| `fzf` | Fuzzy finder: pipe any list into it (`ls \| fzf`); powers Ctrl+T / Alt+C |
| `fd` | Find files by name, fast (`fd config`, `fd -e py`) |
| `rg` | ripgrep: search text in files, fast (`rg TODO`) |
| `bat` | Syntax-coloured file viewer (behind `cat`) |
| `eza` | Modern `ls` (behind `l`, `la`, `lt`, `ll`) |
| `zoxide` | Smart `cd` (`z`, `zi`) |
| `yazi` | File manager with previews (`y`) |
| `tree` | Directory tree |
| `trash-put` / `trash-list` / `trash-restore` / `trash-empty` | Trash from the terminal (`tp` = trash-put) |
| `7z` · `unzip` · `zstd` | Archives (or just `extract file`) |
| `rsync` | Copy and sync folders, local or over ssh |
| `locate` | Find any file on disk instantly by name (indexed) |
| `prename` | Rename many files with a regex |
| `dos2unix` | Fix Windows line endings |
| `xxd` | Hex dump of a file |

### Disk, processes, system
| Tool | What for |
|---|---|
| `btop` | System monitor (`top`) |
| `htop` | Classic process monitor |
| `dust` | Disk usage as a tree |
| `duf` | Free space per disk |
| `gdu` | Interactive disk usage explorer: find and delete what's eating space |
| `fastfetch` | System info with the Fedora logo |
| `inxi` | Detailed hardware info (`inxi -F`) |
| `smartctl` | Disk health (`sudo smartctl -a /dev/nvme0`) |
| `lsof` | Which process has a file or port open |
| `watch` | Re-run a command every N seconds (`watch -n 1 nvidia-smi`) |
| `hyperfine` | Benchmark commands against each other |

### Network
| Tool | What for |
|---|---|
| `ss` | Open ports and connections (`ports`) |
| `curl` · `wget` | HTTP requests and downloads |
| `dig` · `whois` | DNS lookups / domain owner |
| `mtr` · `traceroute` | Where packets get lost on the way |
| `ncat` | Raw TCP/UDP connections (netcat) |
| `tcpdump` | Capture network traffic |
| `tailscale` | Your private VPN mesh |

### Git and development
| Tool | What for |
|---|---|
| `git` · `lazygit` (`lg`) | Version control / its TUI |
| `delta` | Pretty diffs (git uses it automatically) |
| `gh` | GitHub from the terminal: PRs, issues, repos |
| `direnv` | Per-folder env vars from `.envrc` |
| `uv` · `uvx` | Python projects, venvs and one-off tools |
| `node` · `npm` | JavaScript |
| `make` · `cmake` · `ninja` | Builds |
| `gdb` | Debugger |
| `sqlite3` | SQLite shell |
| `jq` | Query and pretty-print JSON (`curl … \| jq .`) |
| `nvim` · `vim` · `nano` | Editors |

### Containers
| Tool | What for |
|---|---|
| `docker` · `lazydocker` (`lzd`) | Containers / their TUI |
| `lazysql` (`lsql`) | Databases TUI (Postgres, MySQL, SQLite, SQL Server) |
| `lazyjournal` (`lj`) | Logs TUI: journald units (system / user), kernel, /var/log files, Docker/Podman containers |
| `podman` | Rootless Docker alternative |
| `toolbox` | Throwaway Fedora containers to try things |

### AI
| Tool | What for |
|---|---|
| `ai` | Local LLM via Ollama (see the `ai` section) |
| `ollama` | Manage local models (`ollama list`, `ollama pull`) |
| `claude` | Claude Code |

### Docs, media, helpers
| Tool | What for |
|---|---|
| `update-all` | Update everything now (runs weekly on its own; `--user` skips dnf) |
| `tldr` | Quick examples for any command |
| `glow` | Render Markdown (`glow README.md`); `glow` alone browses the `.md` files in a folder |
| `ffmpeg` | Convert or cut audio and video |
| `magick` | ImageMagick: resize and convert images |
| `pwgen` | Generate passwords |
| `fpaste` | Upload text to a pastebin and get a link |
| `wl-copy` · `wl-paste` | Clipboard from the terminal (`cat file \| wl-copy`) |
| `atuin` | Shell history database (Ctrl+R) |
| `thefuck` | Fix the last failed command (`fuck`) |
| `starship` | The prompt |
| `tmux` | Sessions, windows and panes |

## TUI apps: basic keys
- **lazygit**: `space` stage/unstage · `c` commit · `P` push · `p` pull · `|` switch diff renderer · `?` help
- **yazi** (Markdown files are previewed rendered): `Enter` / `l` go into a folder or open a file · `h/j/k` move · `space` select · `y`/`x`/`p` copy/cut/paste · `a` create · `r` rename · `d` trash · `/` search · `z` jump with zoxide · `q` quit
- **lazydocker**: `[`/`]` tabs · `l` logs · `s` stop · `r` restart · `d` remove
- **lazysql**: `Enter` connect · `H`/`L` tree / table · `Ctrl+E` SQL editor · `Backspace` back to connections · `?` help · `q` quit
- **lazyjournal**: `Tab` next panel · `j`/`k` move · `Enter` open a log · `/` filter (`Ctrl+K` filter mode: default / fuzzy / regex) · `Ctrl+P` priority · `Ctrl+D` Docker / Podman · `Ctrl+T` timestamps · `F1` help · `Ctrl+C` quit
- **btop**: `h/j/k/l` move · `f` filter · `k` kill process · `m` menu
