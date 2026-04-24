# Changelog

## 0.1.0 — 2026-04-24

Initial release.

- ASCII boot banner + fake init sequence
- First-run account setup (sha256-hashed local credentials)
- Login screen with 3-attempt lockout
- JARVIS voice via `espeak` / `festival` / `termux-tts-speak`
- Maker intro with Kashsight socials
- Commands: `help`, `about`, `ask`, `joke`, `fact`, `meme`, `weather`,
  `sysinfo`, `ls`, `ll`, `cd`, `clear`, `voice`, `whoami`, `reset-auth`,
  `exit`
- Shell fallthrough for any unknown input
- Non-destructive installer + uninstaller
