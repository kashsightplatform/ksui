# Changelog

## 0.2.0 — 2026-04-24

### Added
- **One-shot modes** — run commands without entering the REPL:
  `ksui ask <q>`, `ksui joke`, `ksui fact`, `ksui weather [city]`,
  `ksui sysinfo`, `ksui motd`, `ksui update`, `ksui theme [name]`
- **`ksui update`** — self-updates the install via `git pull` + re-runs
  the installer to refresh assets.
- **Prompt themes** — `ksui theme [name]` lists / switches. Three
  built-ins: `ksui` (JARVIS-blue, default), `minimal`, `cyberpunk`.
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
  sysinfo + datetime + disk) instead of the JARVIS-face mini-banner.
- `ksui --help` shows the new usage with one-shot subcommands.

### Removed
- Dropped the old `jarvis.txt` mini-face from the post-login screen.

## 0.1.0 — 2026-04-24

Initial release.

- ASCII boot banner + fake init sequence
- First-run account setup (sha256-hashed local credentials)
- Login screen with 3-attempt lockout
- JARVIS voice via `espeak` / `festival` / `termux-tts-speak`
- Maker intro with Kashsight socials
- Commands: `help`, `about`, `ask`, `joke`, `fact`, `meme`, `weather`,
  `sysinfo`, `ls`, `ll`, `cd`, `clear`, `voice`, `whoami`,
  `reset-auth`, `exit`
- Non-destructive installer + uninstaller
- Vendored KSH framework + motd + prompt theme (no oh-my-zsh / p10k /
  external motd dependency)
