#!/data/data/com.termux/files/usr/bin/env bash
# KSUI installer
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/kashsight/ksui/main/install/install.sh | bash
#
# Non-destructive: only installs missing packages, never removes or
# downgrades anything you already have. Existing Termux font and color
# scheme are backed up (.ksui-backup) before being replaced so the
# uninstaller can restore them.
set -euo pipefail

REPO="${KSUI_REPO:-https://github.com/kashsight/ksui.git}"
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

# Update mode: when set, the installer behaves non-destructively — it only
# pulls upstream code/feature/fix changes and refreshes the KSUI managed
# block in ~/.zshrc. It WILL NOT overwrite the user's font, colors, theme
# selection, banner, or extra-keys layout, even if those have backups.
# `cmd::update` sets this; first-time installs leave it unset.
KSUI_UPDATE_MODE="${KSUI_UPDATE_MODE:-0}"

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
  if (( KSUI_UPDATE_MODE )) && [[ -f "$TERMUX_DIR/font.ttf" ]]; then
    info "Update mode: keeping existing font ($TERMUX_DIR/font.ttf)"
    return
  fi
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

  info "Downloading FiraCode Nerd Font (required for icons + KAI glyphs)…"
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
  if (( KSUI_UPDATE_MODE )) && [[ -f "$TERMUX_DIR/colors.properties" ]]; then
    info "Update mode: keeping existing color scheme"
    return
  fi
  mkdir -p "$TERMUX_DIR"

  local dest="$TERMUX_DIR/colors.properties"
  backup_file "$dest"
  cp "$INSTALL_DIR/assets/colors.properties" "$dest" && \
    say "Installed KAI-blue color scheme"
}

install_extra_keys() {
  (( KSUI_SKIP_KEYS )) && { info "Skipping extra-keys layout (KSUI_SKIP_KEYS=1)"; return; }
  [[ -f "$INSTALL_DIR/assets/termux.properties" ]] || return 0
  if (( KSUI_UPDATE_MODE )) && [[ -f "$TERMUX_DIR/termux.properties" ]]; then
    info "Update mode: keeping existing extra-keys layout"
    return
  fi
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

  local rendered
  rendered=$(sed "s|__KSUI_INSTALL_DIR__|$INSTALL_DIR|g" "$tmpl")

  # Extract just the managed block from the rendered template
  local block
  block=$(awk '/# KSUI-BEGIN/,/# KSUI-END/' <<<"$rendered")

  # Case A — existing .zshrc already has KSUI markers: only refresh the
  # managed block, never touch the rest. Safe for both fresh installs and
  # `ksui update`.
  if [[ -f $zshrc ]] && grep -q '# KSUI-BEGIN' "$zshrc"; then
    local tmp="${zshrc}.ksui.tmp"
    awk -v block="$block" '
      /# KSUI-BEGIN/ { in_block=1; print block; next }
      /# KSUI-END/   { in_block=0; next }
      !in_block      { print }
    ' "$zshrc" > "$tmp" && mv "$tmp" "$zshrc"
    say "Refreshed KSUI block in $zshrc"
    return
  fi

  # Case B — update mode but no KSUI block found: append the block, do
  # NOT wipe the user's .zshrc. They asked us to fix bugs, not their dotfiles.
  if (( KSUI_UPDATE_MODE )); then
    [[ -f $zshrc ]] && backup_file "$zshrc"
    printf '\n%s\n' "$block" >> "$zshrc"
    say "Appended KSUI block to $zshrc (update mode)"
    return
  fi

  # Case C — fresh install: back up the existing .zshrc once, then write
  # the full KSUI .zshrc on top. The user explicitly invoked the installer.
  [[ -f $zshrc ]] && backup_file "$zshrc"
  printf '%s\n' "$rendered" > "$zshrc"
  say "Installed KSUI .zshrc (backup: $zshrc.ksui-backup)"
  info "Personal overrides? Put them in ~/.zshrc.local — sourced automatically."
}

install_motd() {
  (( KSUI_SKIP_MOTD )) && { info "Skipping motd (KSUI_SKIP_MOTD=1)"; return; }
  # motd files ship in the repo under $INSTALL_DIR/motd — nothing to fetch.
  # The KSH framework sources init.sh on new interactive shells automatically.
  chmod +x "$INSTALL_DIR/motd/init.sh" "$INSTALL_DIR/motd/motd.d/"* 2>/dev/null || true
  say "KSUI motd ready (shown on new interactive shells)"

  # Disable other motds so KSUI's is the only one that shows.
  # We comment out the motd line in $PREFIX/etc/zprofile (used by
  # GR3YH4TT3R93/termux-motd and similar) and back it up first.
  local zp="$PREFIX/etc/zprofile"
  if [[ -f $zp ]] && grep -qE '^[^#]*etc/motd/init\.sh' "$zp"; then
    backup_file "$zp"
    sed -i -E 's|^([^#]*etc/motd/init\.sh.*)$|# \1  # disabled by KSUI|' "$zp"
    say "Disabled global motd in $zp (backup: $zp.ksui-backup)"
  fi
  # Termux's plain /etc/motd file (if it exists as a regular file): silence
  # by ensuring ~/.hushlogin exists.
  if [[ -f $PREFIX/etc/motd && ! -e $HOME/.hushlogin ]]; then
    : > "$HOME/.hushlogin" && say "Created ~/.hushlogin to silence default Termux motd"
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
pkg_install_if_missing unzip unzip
pkg_install_if_missing coreutils mv
pkg_install_if_missing gawk awk
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
pkg_install_if_missing qrencode qrencode
pkg_install_if_missing termux-api termux-notification

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
