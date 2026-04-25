# KSUI — Kashsight UI

> A KAI-inspired Termux shell UI + zsh framework, made by **Kashsight**.
> Big motd banner with live sysinfo/time/disk panels, voice greetings, `tgpt`-powered commands, fzf keybinds, three prompt themes, and a safe non-destructive installer.

```
 ██╗  ██╗ █████╗ ███████╗██╗  ██╗    ███████╗██╗ ██████╗ ██╗  ██╗████████╗
 ██║ ██╔╝██╔══██╗██╔════╝██║  ██║    ██╔════╝██║██╔════╝ ██║  ██║╚══██╔══╝
 █████╔╝ ███████║███████╗███████║    ███████╗██║██║  ███╗███████║   ██║
 ██╔═██╗ ██╔══██║╚════██║██╔══██║    ╚════██║██║██║   ██║██╔══██║   ██║
 ██║  ██╗██║  ██║███████║██║  ██║    ███████║██║╚██████╔╝██║  ██║   ██║
 ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝    ╚══════╝╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝
                     ⚡ Kashsight • KAI UI ⚡
```

---

## ✨ What you get

**The `ksui` app** (interactive KAI shell):
- 🔐 First-run account setup with sha256-hashed local credentials
- 🤖 KAI voice greeting on every login (`espeak` / `festival` / termux-tts)
- 🎨 Full motd-style banner: system info + date/time + disk panels
- 🔊 Sox-synthesized sound effects (boot sweep, beeps, access chime)
- 🧠 Commands backed by `tgpt`: `ask`, `joke`, `fact`
- 🖼 Memes, weather (`wttr.in`), sysinfo (`neofetch`)

**KSH — our own zsh framework** (replaces oh-my-zsh):
- 📁 Iconified `ls`/`ll`/`la`/`lt` via `lsd`
- 💡 Autosuggestions (→ / Ctrl-F to accept)
- 🎨 Syntax highlighting (green/red for valid/invalid commands)
- 📍 `z` frecent directory jump
- 🔍 **fzf** Ctrl-R history, Ctrl-T files, Alt-C cd — all with preview
- 🎭 Three prompt themes: `ksui` (KAI-blue), `minimal`, `cyberpunk`

**Zero external runtime deps** — we vendor everything. No oh-my-zsh, no powerlevel10k, no external motd repo.

---

## 🚀 Install

```bash
curl -fsSL https://raw.githubusercontent.com/kashsight/ksui/main/install/install.sh | bash
```

The installer:
1. Installs missing packages (git, curl, lsd, tgpt, espeak, sox, fzf, …) — **never touches versions you already have**
2. Downloads FiraCode Nerd Font (for icons + glyphs), backing up existing `~/.termux/font.ttf`
3. Drops our KAI-blue `colors.properties` + 3-row extra-keys layout (both backed up)
4. Patches a managed `# KSUI-BEGIN/END` block into `~/.zshrc`
5. Symlinks `ksui` into `$PREFIX/bin`

Then run:

```bash
ksui            # interactive login + REPL
ksui --help     # all modes
```

---

## 🗣 Commands — interactive REPL

```
help                Show the command menu
about               Maker intro + socials
ask <q...>          Ask KAI anything (tgpt)
joke / fact         AI-generated joke / fun fact
meme                Random meme (with bundled fallback)
weather [city]      Weather via wttr.in
sysinfo             Full system info (neofetch)
motd                Reprint the banner
time / date         Current date & time
ls / ll / cd / clear  (as expected)
voice on|off        Toggle KAI voice
theme [name]        List or switch prompt themes
update              git pull + re-run installer
whoami              Show current KSUI user
reset-auth          Reset username/password
exit / quit         Shut down
```

Anything else is passed to your shell.

---

## ⚡ One-shot mode (no login, no REPL)

```bash
ksui ask "what's a zsh completion function?"
ksui joke
ksui weather nairobi
ksui sysinfo
ksui motd                  # just the banner
ksui theme                 # list themes
ksui theme cyberpunk       # switch
ksui update                # self-update
```

---

## 🎭 Prompt themes (switch anytime)

| Theme | Style |
|---|---|
| `ksui` (default) | 2-line KAI-blue, cyan path + orange git branch |
| `minimal` | Single-line `%1~ ❯`, no git |
| `cyberpunk` | Neon magenta/green, `user@host` + exit code + duration |

```bash
ksui theme cyberpunk
exec zsh            # reload the prompt
```

---

## ⌨️ fzf keybinds (in any KSH shell)

| Key | Action |
|---|---|
| `Ctrl-R` | Fuzzy history search |
| `Ctrl-T` | Fuzzy file picker (with preview), inserts path at cursor |
| `Alt-C` | Fuzzy `cd` |

Requires `fzf` (and optionally `fd` for speed) — installed automatically.

---

## 🧩 Dependencies

The installer installs these **only if missing** and never downgrades:

| Tool | Used for | Required? |
|---|---|---|
| `bash`, `zsh` | the scripts themselves | ✅ |
| `git`, `curl`, `unzip` | install / update / assets | ✅ |
| `lsd` | iconified `ls`/`ll` | recommended |
| `tgpt` | `ask` / `joke` / `fact` | recommended |
| `fzf`, `fd` | Ctrl-R / Ctrl-T / Alt-C | recommended |
| `espeak` | KAI voice | optional |
| `sox` | sound effects | optional |
| `figlet`, `lolcat`, `neofetch` | pretty extras | optional |
| `openssl` | password hashing (falls back to `sha256sum`) | optional |

KSUI **degrades gracefully** — every optional dep is guarded by `command -v`.

---

## 🗑 Uninstall (safe, reversible)

```bash
bash ~/.ksui-app/install/uninstall.sh            # keep credentials
bash ~/.ksui-app/install/uninstall.sh --purge    # wipe credentials too
```

Uninstall:
- ✅ Removes KSUI's install dir + the `ksui` symlink
- ✅ Restores original `~/.termux/font.ttf`, `colors.properties`, `termux.properties` from `.ksui-backup`
- ✅ Strips the managed `# KSUI-BEGIN/END` block from `~/.zshrc`
- ❌ **Never** removes shared deps (`git`, `curl`, `tgpt`, `espeak`, `lsd`, `fzf`, …) — other projects depend on them

---

## ⚙️ Environment variables

| Var | Default | Purpose |
|---|---|---|
| `KSUI_VOICE` | `1` | Set `0` to start muted |
| `KSUI_SOUNDS` | `1` | Set `0` to disable sox beeps |
| `KSUI_CFG` | `~/.ksui` | Credentials + theme preference |
| `KSUI_INSTALL_DIR` | `~/.ksui-app` | Repo install location |
| `KSUI_REPO` | upstream git URL | Override to install from a fork |
| `KSUI_SKIP_FONT` / `_COLORS` / `_KEYS` / `_KSH` / `_MOTD` | `0` | Opt-out toggles for installer |
| `KSH_SKIP_HISTORY` / `_COMPLETION` / `_AUTOSUGGEST` / `_SYNTAX` / `_Z` / `_FZF` / `_THEME` / `_ALIASES` / `_MOTD` | `0` | Opt-out toggles for KSH framework |

---

## 🏗 Architecture

```
ksui/
├── bin/ksui              entrypoint: one-shot modes OR boot → login → REPL
├── lib/                  ui / voice / sound / auth / commands
├── motd/                 logo + sysinfo + datetime + disk (our own, bash)
├── zsh/
│   ├── ksh.zsh           the KSH framework (replaces oh-my-zsh)
│   ├── plugins/          autosuggestions, syntax-highlighting, z, fzf
│   ├── themes/           ksui, minimal, cyberpunk
│   └── zshrc.template    the KSUI-BEGIN/END block
├── assets/               banner, KAI-blue colors, extra-keys, memes
└── install/              install.sh + uninstall.sh
```

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for design principles.

---

## 👤 Maker

Made with ⚡ by **KASHSIGHT**

- 🎬 YouTube — [youtube.com/@kashsight](https://youtube.com/@kashsight)
- 📸 Instagram — [instagram.com/kashsight](https://instagram.com/kashsight)
- 📘 Facebook — [facebook.com/kashsight](https://facebook.com/kashsight)
- 💻 GitHub — [github.com/kashsight](https://github.com/kashsight)

---

## 📜 License

MIT — see [LICENSE](LICENSE).
