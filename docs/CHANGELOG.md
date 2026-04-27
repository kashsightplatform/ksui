# Changelog

## 0.3.0 — 2026-04-25

### Added
- **KAI** — the AI persona replacing JARVIS across all user-facing strings
  (commands, banners, voice, docs). `ksui ask` prompts now say `🤖 KAI:`.
- **News** — `ksui news` prints top 5 Hacker News headlines with URLs.
- **Crypto** — `ksui crypto [coin]` shows USD + KES + 24h change via CoinGecko.
  Accepts aliases (btc/eth/sol/doge/…) or any CoinGecko id.
- **IP** — `ksui ip` shows public IP + city/region/country + org (ipinfo.io).
- **Define** — `ksui define <word>` dictionary lookup (dictionaryapi.dev).
- **QR** — `ksui qr <text>` renders an ANSI QR code (requires qrencode).
- **Notes** — `ksui note <text>` appends to `~/.ksui/notes.md`; `ksui notes` lists.
- **Todo** — `ksui todo [text]` / `todo done N` / `todo rm N` / `todo clear`
  against `~/.ksui/todo.md`.
- **Timer** — `ksui timer <minutes>` pomodoro with voice + chime + notification.
- **Doctor** — `ksui doctor` audits every optional dep and KSUI file with ✓/✗.
- **Password mask** — auth now echoes `*` per keystroke (backspace supported).
- **Disk bar** — motd disk panel shows `[█████░░] 87%  27G/28G` inline.
- Installer pulls `qrencode` and `termux-api` (optional).

### Changed
- **Compact motd** — removed the `Date & Time:` panel; time now lives on the
  prompt's RPROMPT as `HH:MM:SS`.
- **Prompt** — hides the git branch segment by default (less noise).
- **Joke / fact** — each call picks a random topic + nonce so tgpt stops
  repeating the same punchline.
- **Load-average parsing** — robust against `uptime` format variations.
- Installer / repo URL: `kashsight` → `kashsight` (username change).
- Socials: X/Twitter → Facebook in the maker intro.

## 0.2.0 — 2026-04-24

### Added
- **One-shot modes** — run commands without entering the REPL:
  `ksui ask <q>`, `ksui joke`, `ksui fact`, `ksui weather [city]`,
  `ksui sysinfo`, `ksui motd`, `ksui update`, `ksui theme [name]`
- **`ksui update`** — self-updates the install via `git pull` + re-runs
  the installer to refresh assets.
- **Prompt themes** — `ksui theme [name]` lists / switches. Three
  built-ins: `ksui` (KAI-blue, default), `minimal`, `cyberpunk`.
  Selection persisted in `~/.ksui/theme`.
- **fzf integration** in KSH (`zsh/plugins/fzf/`):
  - `Ctrl-R` — fuzzy history search
  - `Ctrl-T` — fuzzy file picker with preview
  - `Alt-C` — fuzzy `cd`
- **Motd date/time panel** (`motd/motd.d/25-datetime`).
- Installer now pulls `fzf` and `fd` (optional).
- REPL commands: `theme`, `update`, `motd`, `time`, `date`.

### Changed
- **Login screen** now uses the full motd (big KASHSIGHT banner +
  sysinfo + datetime + disk) instead of the KAI-face mini-banner.
- `ksui --help` shows the new usage with one-shot subcommands.

### Removed
- Dropped the old `kai.txt` mini-face from the post-login screen.

## 0.1.0 — 2026-04-24

Initial release.

- ASCII boot banner + fake init sequence
- First-run account setup (sha256-hashed local credentials)
- Login screen with 3-attempt lockout
- KAI voice via `espeak` / `festival` / `termux-tts-speak`
- Maker intro with Kashsight socials
- Commands: `help`, `about`, `ask`, `joke`, `fact`, `meme`, `weather`,
  `sysinfo`, `ls`, `ll`, `cd`, `clear`, `voice`, `whoami`,
  `reset-auth`, `exit`
- Non-destructive installer + uninstaller
- Vendored KSH framework + motd + prompt theme (no oh-my-zsh / p10k /
  external motd dependency)
