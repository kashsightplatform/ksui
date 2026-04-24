# Fonts

The installer downloads **FiraCode Nerd Font Regular** at install-time from:

```
https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip
```

This is the font KSUI's UI is designed around (icons in `lsd`, box-drawing in the banner, the JARVIS face glyphs).

We don't commit the TTF itself because:
- It's ~2 MB and Nerd Fonts is already a well-maintained upstream
- The upstream release URL is stable (always `latest`)
- Users get font bug fixes automatically on re-install

If the download ever fails, KSUI still works — the banner falls back to plain box-drawing and `lsd` icons degrade to a unicode theme.
