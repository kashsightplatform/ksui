#!/data/data/com.termux/files/usr/bin/env bash
# KSUI installer
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/kashsight/ksui/main/install/install.sh | bash
#
# Non-destructive: only installs missing packages, never removes or
# downgrades anything you already have.
set -euo pipefail

REPO="${KSUI_REPO:-https://github.com/kashsight/ksui.git}"
PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
INSTALL_DIR="${KSUI_INSTALL_DIR:-$HOME/.ksui-app}"
BIN_LINK="$PREFIX/bin/ksui"

say()  { printf "\033[38;5;120m✔\033[0m %s\n" "$*"; }
warn() { printf "\033[38;5;221m⚠\033[0m %s\n" "$*"; }
err()  { printf "\033[38;5;203m✖\033[0m %s\n" "$*" >&2; }
hr()   { printf '\033[2m%s\033[0m\n' "────────────────────────────────────"; }

banner() {
cat <<'EOF'
 ██╗  ██╗███████╗██╗   ██╗██╗
 ██║ ██╔╝██╔════╝██║   ██║██║
 █████╔╝ ███████╗██║   ██║██║
 ██╔═██╗ ╚════██║██║   ██║██║
 ██║  ██╗███████║╚██████╔╝██║
 ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝
       installer
EOF
}

need_cmd() { command -v "$1" >/dev/null 2>&1; }

pkg_install_if_missing() {
  local pkg=$1 bin=${2:-$1}
  if need_cmd "$bin"; then
    say "$bin already installed — skipping"
    return 0
  fi
  if need_cmd pkg; then
    warn "Installing $pkg via pkg…"
    pkg install -y "$pkg" >/dev/null 2>&1 || warn "pkg install $pkg failed (optional)"
  elif need_cmd apt; then
    warn "Installing $pkg via apt…"
    sudo apt-get install -y "$pkg" >/dev/null 2>&1 || warn "apt install $pkg failed (optional)"
  else
    warn "No package manager found — please install '$pkg' manually"
  fi
}

banner
hr
say "Installing KSUI into: $INSTALL_DIR"
say "Bin symlink         : $BIN_LINK"
hr

# --- 1. dependencies (all optional-friendly; KSUI degrades gracefully) ---
say "Checking dependencies (non-destructive — will NOT remove anything you already use)…"
pkg_install_if_missing git git
pkg_install_if_missing curl curl
pkg_install_if_missing figlet figlet
pkg_install_if_missing lolcat lolcat
pkg_install_if_missing lsd lsd
pkg_install_if_missing neofetch neofetch
pkg_install_if_missing tgpt tgpt
pkg_install_if_missing espeak espeak
pkg_install_if_missing openssl-tool openssl

# --- 2. fetch repo ---
if [[ -d $INSTALL_DIR/.git ]]; then
  say "Existing install found — updating…"
  git -C "$INSTALL_DIR" pull --ff-only || warn "git pull failed, keeping current version"
else
  say "Cloning KSUI…"
  git clone --depth 1 "$REPO" "$INSTALL_DIR"
fi

chmod +x "$INSTALL_DIR/bin/ksui"

# --- 3. symlink into PATH ---
if [[ -w $(dirname "$BIN_LINK") ]]; then
  ln -sf "$INSTALL_DIR/bin/ksui" "$BIN_LINK"
  say "Linked ksui → $BIN_LINK"
else
  warn "Cannot write $BIN_LINK — add this to your PATH manually:"
  printf '   export PATH="%s/bin:$PATH"\n' "$INSTALL_DIR"
fi

# --- 4. done ---
hr
say "KSUI installed successfully!"
printf "\n  Run it with:  \033[1;36mksui\033[0m\n"
printf "  Uninstall  :  \033[1;36mksui --help\033[0m or run the uninstaller\n\n"
printf "  Made by \033[38;5;215m⚡ KASHSIGHT ⚡\033[0m — youtube.com/@kashsight\n\n"
