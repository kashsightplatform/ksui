#!/data/data/com.termux/files/usr/bin/env bash
# KSUI uninstaller — SAFE / NON-DESTRUCTIVE
#
# What this DOES remove:
#   • KSUI install directory (~/.ksui-app by default)
#   • KSUI user config (~/.ksui — credentials)
#   • The `ksui` symlink in $PREFIX/bin
#
# What this will NEVER remove:
#   • Shared dependencies (git, curl, tgpt, espeak, lsd, figlet, lolcat,
#     neofetch, openssl) — you or other apps may depend on them.
#   • Anything outside of KSUI's own files.
#
# Pass --purge-config to also remove ~/.ksui (credentials). Otherwise your
# credentials are kept in case you reinstall later.
set -eu

PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
INSTALL_DIR="${KSUI_INSTALL_DIR:-$HOME/.ksui-app}"
CFG_DIR="$HOME/.ksui"
BIN_LINK="$PREFIX/bin/ksui"

say()  { printf "\033[38;5;120m✔\033[0m %s\n" "$*"; }
warn() { printf "\033[38;5;221m⚠\033[0m %s\n" "$*"; }
info() { printf "\033[38;5;75mℹ\033[0m %s\n" "$*"; }

PURGE_CFG=0
for a in "$@"; do
  case "$a" in
    --purge-config|--purge) PURGE_CFG=1 ;;
    --help|-h)
      sed -n '2,16p' "$0"; exit 0 ;;
  esac
done

info "KSUI uninstaller — will ONLY remove KSUI's own files."
info "Shared dependencies (git, curl, tgpt, espeak, lsd, …) will be kept."
echo

read -r -p "Proceed with uninstall? [y/N] " yn
[[ ${yn,,} == y* ]] || { warn "Aborted."; exit 0; }

# 1. symlink
if [[ -L $BIN_LINK || -f $BIN_LINK ]]; then
  rm -f "$BIN_LINK" && say "Removed $BIN_LINK"
else
  info "No symlink at $BIN_LINK — skipping"
fi

# 2. install dir
if [[ -d $INSTALL_DIR ]]; then
  rm -rf "$INSTALL_DIR" && say "Removed $INSTALL_DIR"
else
  info "No install dir at $INSTALL_DIR — skipping"
fi

# 3. config (opt-in)
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
