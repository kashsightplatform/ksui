# KSUI — Kashsight UI

> A JARVIS-inspired Termux shell UI, made by **Kashsight**.
> Login screen, ASCII banner, voice greetings, `tgpt`-powered commands (joke, ask, fact, meme, weather) and a clean icon-rich file listing.

```
 ██╗  ██╗███████╗██╗   ██╗██╗
 ██║ ██╔╝██╔════╝██║   ██║██║
 █████╔╝ ███████╗██║   ██║██║
 ██╔═██╗ ╚════██║██║   ██║██║
 ██║  ██╗███████║╚██████╔╝██║
 ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝
```

---

## ✨ Features

- 🔐 **First-run account setup** — user picks their own username + password (sha256-hashed, stored locally at `~/.ksui/auth`, 0600)
- 🤖 **JARVIS voice** — `espeak` (preferred), `festival`, or Termux's TTS for a greeting on every login
- 🎨 **ASCII boot sequence** with colored status ticks
- 📁 **Iconified `ls`/`ll`** via `lsd` + your existing FiraCode font — matches the Termux UI you already have
- 🧠 **`tgpt`-powered commands**: `ask`, `joke`, `fact`
- 🖼 **Memes** via meme-api.com
- ☁️ **Weather** via `wttr.in`
- 🧾 **`sysinfo`** via `neofetch`
- 🎙 **Toggle voice** anytime: `voice on` / `voice off`
- 💻 **Shell fallthrough** — any unknown input is passed to your shell, so KSUI never gets in your way

---

## 🚀 Install

One-line install (Termux / Debian / Ubuntu):

```bash
curl -fsSL https://raw.githubusercontent.com/kashsightplatform/ksui/main/install/install.sh | bash
```

Or manually:

```bash
git clone https://github.com/kashsightplatform/ksui.git ~/.ksui-app
ln -sf ~/.ksui-app/bin/ksui $PREFIX/bin/ksui
```

Then just run:

```bash
ksui
```

On first launch you'll be asked to create a username + password. On every subsequent launch KSUI will ask you to log in, then greet you by name (with voice, if available).

---

## 🧩 Dependencies

The installer will install these **only if missing** — it never touches versions you already have:

| Tool      | Used for                         | Required? |
|-----------|----------------------------------|-----------|
| `bash`    | the script itself                | ✅        |
| `git`     | install / update                 | ✅        |
| `curl`    | meme + weather APIs, install     | ✅        |
| `tgpt`    | `ask`, `joke`, `fact` commands   | recommended |
| `lsd`     | iconified `ls`/`ll`              | recommended |
| `figlet`  | extra banners                    | optional  |
| `lolcat`  | rainbow banner                   | optional  |
| `neofetch`| `sysinfo`                        | optional  |
| `espeak`  | JARVIS voice                     | optional (silent if absent) |
| `openssl` | password hashing (falls back to `sha256sum`) | optional |

KSUI **degrades gracefully** — every optional dep is guarded by a `command -v` check.

---

## 🗣 Commands

```
help            Show the command menu
about           Maker intro + socials
ask <q...>      Ask JARVIS anything (tgpt)
joke            Tell a joke (tgpt)
fact            Random fun fact (tgpt)
meme            Fetch a random meme
weather [city]  Weather from wttr.in
sysinfo         System info (neofetch)
ls / ll         List files with icons
cd <dir>        Change directory
clear / cls     Clear screen
voice on|off    Toggle JARVIS voice
whoami          Show current KSUI user
reset-auth      Reset username/password
exit / quit     Shut down KSUI
```

Anything else is passed straight to your shell.

---

## 🗑 Uninstall (safe, non-destructive)

```bash
bash ~/.ksui-app/install/uninstall.sh
```

The uninstaller:

- ✅ Removes KSUI's own install dir and the `ksui` symlink
- ❌ **Never** removes shared dependencies (`git`, `curl`, `tgpt`, `espeak`, `lsd`, `figlet`, `lolcat`, `neofetch`, `openssl`) — you or other projects may depend on them
- 🔒 Keeps your credentials at `~/.ksui` unless you pass `--purge-config`

If you want a specific dep gone, remove it yourself, e.g. `pkg uninstall tgpt`.

---

## ⚙️ Environment variables

| Var                | Default           | Purpose                          |
|--------------------|-------------------|----------------------------------|
| `KSUI_VOICE`       | `1`               | `0` to start muted               |
| `KSUI_CFG`         | `~/.ksui`         | Where auth file lives            |
| `KSUI_INSTALL_DIR` | `~/.ksui-app`     | Where the repo is cloned         |
| `KSUI_REPO`        | upstream git URL  | Override to install from a fork  |

---

## 👤 Maker

Made with ⚡ by **KASHSIGHT**

- 🎬 YouTube — [youtube.com/@kashsight](https://youtube.com/@kashsight)
- 📸 Instagram — [instagram.com/kashsight](https://instagram.com/kashsight)
- 🐦 X/Twitter — [x.com/kashsight](https://x.com/kashsight)
- 💻 GitHub — [github.com/kashsight](https://github.com/kashsight)

> **Note:** replace the handles above with your actual URLs if they differ — edit `lib/ui.sh` (`ui::maker_intro`) and this README.

---

## 📜 License

MIT — see [LICENSE](LICENSE).
