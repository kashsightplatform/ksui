#!/data/data/com.termux/files/usr/bin/env bash
# KSUI installer
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/kashsightplatform/ksui/main/install/install.sh | bash
#
# Non-destructive: only installs missing packages, never removes or
# downgrades anything you already have. Existing Termux font and color
# scheme are backed up (.ksui-backup) before being replaced so the
# uninstaller can restore them.
set -euo pipefail

REPO="${KSUI_REPO:-https://github.com/kashsightplatform/ksui.git}"
PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
INSTALL_DIR="${KSUI_INSTALL_DIR:-$HOME/.ksui-app}"
BIN_LINK="$PREFIX/bin/ksui"
TERMUX_DIR="${TERMUX_DIR:-$HOME/.termux}"

# opt-outs
KSUI_SKIP_FONT="${KSUI_SKIP_FONT:-0}"
KSUI_SKIP_COLORS="${KSUI_SKIP_COLORS:-0}"
KSUI_SKIP_SOUNDS="${KSUI_SKIP_SOUNDS:-0}"
KSUI_SKIP_KEYS="${KSUI_SKIP_KEYS:-0}"
KSUI_SKIP_KSH="${KSUI_SKIP_KSH:-0}"
KSUI_SKIP_MOTD="${KSUI_SKIP_MOTD:-0}"

say()  { printf "\033[38;5;120m✔\033[0m %s\n" "$*"; }
warn() { printf "\033[38;5;221m⚠\033[0m %s\n" "$*"; }
err()  { printf "\033[38;5;203m✖\033[0m %s\n" "$*" >&2; }
info() { printf "\033[38;5;75mℹ\033[0m %s\n" "$*"; }
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

backup_file() {
  # backup_file <path>  → moves path → path.ksui-backup (only once)
  local f=$1
  [[ -e $f ]] || return 0
  [[ -e $f.ksui-backup ]] && { info "Backup already exists: $f.ksui-backup"; return 0; }
  cp -a "$f" "$f.ksui-backup" && say "Backed up $f → $f.ksui-backup"
}

install_font() {
  (( KSUI_SKIP_FONT )) && { info "Skipping font install (KSUI_SKIP_FONT=1)"; return; }
  mkdir -p "$TERMUX_DIR"

  local font_dest="$TERMUX_DIR/font.ttf"
  local bundled="$INSTALL_DIR/assets/fonts/FiraCodeNerdFont-Regular.ttf"

  # Prefer the bundled font — offline, no network, no flake
  if [[ -f $bundled ]]; then
    backup_file "$font_dest"
    cp "$bundled" "$font_dest" && say "Installed bundled FiraCode Nerd Font"
    return
  fi

  need_cmd curl || { warn "curl missing and no bundled font, cannot install font"; return; }
  backup_file "$font_dest"

  info "Downloading FiraCode Nerd Font (required for icons + JARVIS glyphs)…"
  local tmp
  tmp="$(mktemp -d "${TMPDIR:-$PREFIX/tmp}/ksui-font.XXXXXX")" || {
    warn "Could not create tempdir, skipping font"; return; }

  local zip_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"
  if curl -fsSL --retry 2 -o "$tmp/font.zip" "$zip_url"; then
    if need_cmd unzip; then
      unzip -jo "$tmp/font.zip" "FiraCodeNerdFont-Regular.ttf" -d "$tmp" >/dev/null 2>&1 || \
      unzip -jo "$tmp/font.zip" "*Regular*.ttf" -d "$tmp" >/dev/null 2>&1 || true
      local ttf
      ttf="$(ls "$tmp"/*.ttf 2>/dev/null | head -n1 || true)"
      if [[ -n $ttf ]]; then
        cp "$ttf" "$font_dest" && say "Installed FiraCode Nerd Font"
      else
        warn "Font archive had no TTF inside, skipping"
      fi
    else
      warn "unzip not installed, skipping font extraction"
    fi
  else
    warn "Font download failed (network?), skipping"
  fi
  rm -rf "$tmp"
}

install_colors() {
  (( KSUI_SKIP_COLORS )) && { info "Skipping color scheme (KSUI_SKIP_COLORS=1)"; return; }
  [[ -f "$INSTALL_DIR/assets/colors.properties" ]] || return 0
  mkdir -p "$TERMUX_DIR"

  local dest="$TERMUX_DIR/colors.properties"
  backup_file "$dest"
  cp "$INSTALL_DIR/assets/colors.properties" "$dest" && \
    say "Installed JARVIS-blue color scheme"
}

install_extra_keys() {
  (( KSUI_SKIP_KEYS )) && { info "Skipping extra-keys layout (KSUI_SKIP_KEYS=1)"; return; }
  [[ -f "$INSTALL_DIR/assets/termux.properties" ]] || return 0
  mkdir -p "$TERMUX_DIR"

  local dest="$TERMUX_DIR/termux.properties"
  backup_file "$dest"
  cp "$INSTALL_DIR/assets/termux.properties" "$dest" && \
    say "Installed 3-row extra-keys layout"
}

reload_termux() {
  if need_cmd termux-reload-settings; then
    termux-reload-settings 2>/dev/null || true
    say "Reloaded Termux settings (font + colors active)"
  else
    info "Run 'termux-reload-settings' or restart Termux to apply font/colors"
  fi
}

install_ksh() {
  (( KSUI_SKIP_KSH )) && { info "Skipping KSH shell framework (KSUI_SKIP_KSH=1)"; return; }
  local zshrc="$HOME/.zshrc"
  local tmpl="$INSTALL_DIR/zsh/zshrc.template"
  [[ -f $tmpl ]] || return 0

  # Build the KSUI block
  local block
  block=$(sed "s|__KSUI_INSTALL_DIR__|$INSTALL_DIR|g" "$tmpl")

  # Backup existing .zshrc (once)
  [[ -f $zshrc ]] && backup_file "$zshrc"

  # If already has a KSUI block, replace it; else append
  if [[ -f $zshrc ]] && grep -q '# KSUI-BEGIN' "$zshrc"; then
    local tmp="${zshrc}.ksui.tmp"
    awk -v block="$block" '
      /# KSUI-BEGIN/ { in_block=1; print block; next }
      /# KSUI-END/   { in_block=0; next }
      !in_block      { print }
    ' "$zshrc" > "$tmp" && mv "$tmp" "$zshrc"
    say "Updated KSUI block in $zshrc"
  else
    printf '\n%s\n' "$block" >> "$zshrc"
    say "Appended KSUI block to $zshrc"
  fi
}

install_motd() {
  (( KSUI_SKIP_MOTD )) && { info "Skipping motd (KSUI_SKIP_MOTD=1)"; return; }
  # motd files ship in the repo under $INSTALL_DIR/motd — nothing to fetch.
  # The KSH framework sources init.sh on new interactive shells automatically.
  chmod +x "$INSTALL_DIR/motd/init.sh" "$INSTALL_DIR/motd/motd.d/"* 2>/dev/null || true
  say "KSUI motd ready (shown on new interactive shells)"
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
pkg_install_if_missing unzip unzip
pkg_install_if_missing figlet figlet
pkg_install_if_missing lolcat lolcat
pkg_install_if_missing lsd lsd
pkg_install_if_missing neofetch neofetch
pkg_install_if_missing tgpt tgpt
pkg_install_if_missing espeak espeak
pkg_install_if_missing openssl-tool openssl
pkg_install_if_missing sox play
pkg_install_if_missing fzf fzf
pkg_install_if_missing fd fd

# --- 2. fetch repo ---
if [[ -d $INSTALL_DIR/.git ]]; then
  say "Existing install found — updating…"
  git -C "$INSTALL_DIR" pull --ff-only || warn "git pull failed, keeping current version"
else
  say "Cloning KSUI…"
  git clone --depth 1 "$REPO" "$INSTALL_DIR"
fi

chmod +x "$INSTALL_DIR/bin/ksui"

# --- 3. font + colors + sounds + ksh + motd ---
install_font
install_colors
install_extra_keys
install_motd
install_ksh
# sounds ship inside the repo — nothing else to fetch for them

# --- 4. symlink into PATH ---
if [[ -w $(dirname "$BIN_LINK") ]]; then
  ln -sf "$INSTALL_DIR/bin/ksui" "$BIN_LINK"
  say "Linked ksui → $BIN_LINK"
else
  warn "Cannot write $BIN_LINK — add this to your PATH manually:"
  printf '   export PATH="%s/bin:$PATH"\n' "$INSTALL_DIR"
fi

# --- 5. reload termux so font/colors take effect ---
reload_termux

# --- 6. done ---
hr
say "KSUI installed successfully!"
printf "\n  Run it with:  \033[1;36mksui\033[0m\n"
printf "  Uninstall  :  \033[1;36mbash %s/install/uninstall.sh\033[0m\n\n" "$INSTALL_DIR"
printf "  Made by \033[38;5;215m⚡ KASHSIGHT ⚡\033[0m — youtube.com/@kashsight\n\n"
