# KSUI Architecture

```
ksui/
├── bin/
│   └── ksui             # entrypoint: boot → login → REPL
├── lib/
│   ├── ui.sh            # colors, banners, ls/ll wrappers, status ticks
│   ├── voice.sh         # espeak / festival / termux-tts abstraction
│   ├── auth.sh          # first-run setup + login (sha256 hash, 0600 file)
│   └── commands.sh      # all user-facing commands (ask/joke/meme/…)
├── assets/
│   ├── banner.txt       # KSUI ASCII logo
│   └── jarvis.txt       # JARVIS face
├── install/
│   ├── install.sh       # non-destructive installer (curl|bash friendly)
│   └── uninstall.sh     # safe uninstall: never touches shared deps
└── docs/
    └── ARCHITECTURE.md  # this file
```

## Design principles

1. **Non-destructive by default.** The installer only installs *missing*
   packages; the uninstaller only removes KSUI's own files. Shared tools
   (`git`, `curl`, `tgpt`, `espeak`, `lsd`, …) are never touched because
   other projects on the user's machine may depend on them.

2. **Degrade gracefully.** Every optional dependency is gated by
   `command -v`. If `espeak` isn't present, the UI is silent but still
   works. If `tgpt` isn't present, AI commands print a helpful
   "install tgpt" hint instead of crashing.

3. **Stay out of the user's way.** Unknown input in the REPL is passed
   straight to the shell via `eval "$line"`, so KSUI never blocks a
   workflow the user already has.

4. **Local-only auth.** Passwords are sha256-hashed and stored at
   `~/.ksui/auth` with `0600` permissions. No network, no telemetry.

## Launch flow

```
ksui
  ├─ boot sequence (ASCII + fake init ticks, 1s)
  ├─ auth::login
  │    └─ if no creds → auth::setup (first run)
  ├─ post-login: banner + JARVIS face + voice::greet
  └─ REPL (dispatch → command modules → shell fallthrough)
```

## Extending KSUI

Add a new command:

1. Add a `cmd::mything()` function to `lib/commands.sh`.
2. Add a dispatch case to `ksui::repl` in `bin/ksui`.
3. Add the command to `cmd::help` and the README table.
