#!/data/data/com.termux/files/usr/bin/env bash
# KSUI — auth (first-run setup + login)

KSUI_CFG="${KSUI_CFG:-$HOME/.ksui}"
KSUI_AUTH="$KSUI_CFG/auth"

auth::_hash() {
  # sha256; prefer openssl, fallback sha256sum
  if command -v openssl >/dev/null 2>&1; then
    printf '%s' "$1" | openssl dgst -sha256 | awk '{print $NF}'
  else
    printf '%s' "$1" | sha256sum | awk '{print $1}'
  fi
}

auth::setup() {
  mkdir -p "$KSUI_CFG"
  chmod 700 "$KSUI_CFG"
  ui::hr
  printf "  ${C_CYAN}${C_BOLD}First-run setup${C_RESET} — create your KSUI credentials\n"
  ui::hr
  local u p p2
  while :; do
    read -r -p "  👤 Choose a username: " u
    [[ -n $u ]] && break
  done
  while :; do
    read -r -s -p "  🔑 Choose a password: " p; echo
    read -r -s -p "  🔑 Confirm password : " p2; echo
    if [[ -z $p ]]; then
      ui::say_status ERR "Password cannot be empty"
    elif [[ $p != "$p2" ]]; then
      ui::say_status ERR "Passwords do not match, try again"
    else
      break
    fi
  done
  umask 077
  {
    printf 'KSUI_USER=%s\n' "$u"
    printf 'KSUI_HASH=%s\n' "$(auth::_hash "$p")"
    printf 'KSUI_CREATED=%s\n' "$(date -Iseconds 2>/dev/null || date)"
  } > "$KSUI_AUTH"
  ui::say_status OK "Credentials saved to $KSUI_AUTH"
  sleep 1
}

auth::login() {
  [[ -f $KSUI_AUTH ]] || auth::setup
  # shellcheck disable=SC1090
  source "$KSUI_AUTH"

  local tries=3 u p
  while (( tries > 0 )); do
    ui::hr
    printf "  ${C_BLUE}🔐 KSUI Authentication${C_RESET}\n"
    ui::hr
    read -r -p "  👤 Username: " u
    read -r -s -p "  🔑 Password: " p; echo
    if [[ $u == "$KSUI_USER" && "$(auth::_hash "$p")" == "$KSUI_HASH" ]]; then
      export KSUI_USER
      ui::say_status OK "Access granted. Welcome back, $KSUI_USER."
      sleep 0.6
      return 0
    fi
    ((tries--))
    ui::say_status ERR "Invalid credentials. Attempts left: $tries"
  done
  ui::say_status ERR "Too many failed attempts. System lockdown."
  voice::say "Access denied. Lockdown engaged." ; sleep 1
  return 1
}

auth::reset() {
  rm -f "$KSUI_AUTH"
  ui::say_status OK "Credentials cleared. Run ksui again to set up new ones."
}
