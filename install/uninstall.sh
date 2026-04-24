#!/data/data/com.termux/files/usr/bin/env bash
# KSUI uninstaller — SAFE / NON-DESTRUCTIVE
#
# Removes:
#   • KSUI install dir (~/.ksui-app by default)
#   • `ksui` symlink in $PREFIX/bin
#   • Restores ~/.termux/font.ttf, colors.properties, termux.properties
#     from their .ksui-backup files if present.
#   • With --purge-config: also removes ~/.ksui (credentials)
#
# Never removes:
#   • Shared deps (git, curl, tgpt, espeak, lsd, figlet, lolcat, neofetch,
#     openssl, sox, unzip) — other projects may depend on them.
set -eu

PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
INSTALL_DIR="${KSUI_INSTALL_DIR:-$HOME/.ksui-app}"
CFG_DIR="$HOME/.ksui"
BIN_LINK="$PREFIX/bin/ksui"
TERMUX_DIR="${TERMUX_DIR:-$HOME/.termux}"

say()  { printf "\033[38;5;120m✔\033[0m %s\n" "$*"; }
warn() { printf "\033[38;5;221m⚠\033[0m %s\n" "$*"; }
info() { printf "\033[38;5;75mℹ\033[0m %s\n" "$*"; }

PURGE_CFG=0
for a in "$@"; do
  case "$a" in
    --purge-config|--purge) PURGE_CFG=1 ;;
    --help|-h)
      sed -n '2,18p' "$0"; exit 0 ;;
  esac
done

info "KSUI uninstaller — will ONLY remove KSUI's own files."
info "Shared dependencies (git, curl, tgpt, espeak, lsd, …) will be kept."
echo

read -r -p "Proceed with uninstall? [y/N] " yn
[[ ${yn,,} == y* ]] || { warn "Aborted."; exit 0; }

restore_or_remove() {
  # restore_or_remove <path>
  # If <path>.ksui-backup exists → restore it. Otherwise remove <path>
  # IF AND ONLY IF we can tell KSUI placed it there (i.e. there's no
  # backup, meaning it didn't exist before install). We can't prove that
  # though, so we err on the side of keeping the file and just inform.
  local f=$1
  if [[ -e $f.ksui-backup ]]; then
    mv -f "$f.ksui-backup" "$f" && say "Restored $f from backup"
  else
    info "No backup for $f — leaving as-is (KSUI can't prove it owned it)"
  fi
}

# 1. symlink
if [[ -L $BIN_LINK || -f $BIN_LINK ]]; then
  rm -f "$BIN_LINK" && say "Removed $BIN_LINK"
else
  info "No symlink at $BIN_LINK — skipping"
fi

# 2. font + colors + extra-keys restore
restore_or_remove "$TERMUX_DIR/font.ttf"
restore_or_remove "$TERMUX_DIR/colors.properties"
restore_or_remove "$TERMUX_DIR/termux.properties"
command -v termux-reload-settings >/dev/null 2>&1 && \
  termux-reload-settings 2>/dev/null && say "Termux settings reloaded"

# 3. install dir
if [[ -d $INSTALL_DIR ]]; then
  rm -rf "$INSTALL_DIR" && say "Removed $INSTALL_DIR"
else
  info "No install dir at $INSTALL_DIR — skipping"
fi

# 4. config (opt-in)
if (( PURGE_CFG )); then
  if [[ -d $CFG_DIR ]]; then
    rm -rf "$CFG_DIR" && say "Removed $CFG_DIR (credentials purged)"
  fi
else
  if [[ -d $CFG_DIR ]]; then
    info "Kept $CFG_DIR (contains your credentials)."
    info "Re-run with --purge-config to remove it too."
  fi
fi

echo
say "KSUI uninstalled. Dependencies left untouched."
info "If you want to remove a specific dependency, do it manually, e.g.:"
info "  pkg uninstall tgpt"
