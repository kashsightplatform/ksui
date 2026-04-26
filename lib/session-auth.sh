#!/data/data/com.termux/files/usr/bin/env bash
# KSUI — session lock. Runs auth::login on shell startup.
# Skipped if: stdin is not a tty, no creds set up yet, or the user has
# opted out via `touch ~/.ksui/no-lock`.

KSUI_HOME="${KSUI_HOME:-$HOME/ksui}"
KSUI_CFG="${KSUI_CFG:-$HOME/.ksui}"

# Don't lock non-interactive shells, scripts, or ksui's own REPL.
[[ -t 0 && -t 1 ]] || exit 0
[[ -n $KSUI_REPL ]] && exit 0
[[ -f "$KSUI_CFG/no-lock" ]] && exit 0

# If creds haven't been created yet, run setup so the user has something
# to log in with. Skip silently if the auth lib is missing.
[[ -r "$KSUI_HOME/lib/ui.sh"   ]] && source "$KSUI_HOME/lib/ui.sh"
[[ -r "$KSUI_HOME/lib/auth.sh" ]] || exit 0
source "$KSUI_HOME/lib/auth.sh"

# Render a small banner so the lock screen feels intentional.
clear 2>/dev/null
[[ -x "$KSUI_HOME/motd/motd.d/10-ksui-logo" ]] \
  && "$KSUI_HOME/motd/motd.d/10-ksui-logo"

if [[ ! -f "$KSUI_AUTH" ]]; then
  auth::setup
fi
auth::login || {
  # Lockdown: refuse to drop the user at a usable shell.
  printf '\n%sShell locked.%s Close this session and try again.\n' \
    "${C_RED:-}" "${C_RESET:-}"
  exec sleep 86400
}
