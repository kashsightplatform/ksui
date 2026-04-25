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

# Read a password while echoing `*` per keystroke. Supports backspace.
# Usage: auth::_read_password "  🔑 Password: " VARNAME
auth::_read_password() {
  local prompt=$1 __outvar=$2
  local pw="" char
  printf '%s' "$prompt"
  # Turn off canonical mode + echo so we can handle each byte
  stty -echo -icanon min 1 time 0 2>/dev/null
  while IFS= read -r -n1 char; do
    # Enter = done (some terminals send empty when Enter pressed in raw mode)
    if [[ -z $char ]]; then
      break
    fi
    # Backspace (DEL 0x7f or ^H 0x08)
    if [[ $char == $'\x7f' || $char == $'\b' ]]; then
      if [[ -n $pw ]]; then
        pw=${pw%?}
        printf '\b \b'
      fi
      continue
    fi
    # Ignore other control chars
    if [[ $char == $'\x03' ]]; then  # Ctrl-C
      stty sane 2>/dev/null
      printf '\n'; return 130
    fi
    pw+=$char
    printf '*'
  done
  stty sane 2>/dev/null
  printf '\n'
  printf -v "$__outvar" '%s' "$pw"
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
    auth::_read_password "  🔑 Choose a password: " p
    auth::_read_password "  🔑 Confirm password : " p2
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

  # If stdin isn't a real terminal (e.g. ksui was auto-launched in a context
  # where the parent shell still owns the line editor), bail out gracefully
  # instead of burning through 3 phantom "empty password" attempts.
  if [[ ! -t 0 ]]; then
    ui::say_status WARN "No interactive terminal — skipping auth."
    ui::say_status INFO "Run 'ksui' manually to log in."
    return 1
  fi
  stty sane 2>/dev/null

  local tries=3 u p
  while (( tries > 0 )); do
    ui::hr
    printf "  ${C_BLUE}🔐 KSUI Authentication${C_RESET}\n"
    ui::hr
    read -r -p "  👤 Username: " u
    auth::_read_password "  🔑 Password: " p
    if [[ $u == "$KSUI_USER" && "$(auth::_hash "$p")" == "$KSUI_HASH" ]]; then
      export KSUI_USER
      command -v sound::chime >/dev/null 2>&1 && sound::chime
      ui::say_status OK "Access granted. Welcome back, $KSUI_USER."
      sleep 0.6
      return 0
    fi
    ((tries--))
    command -v sound::deny >/dev/null 2>&1 && sound::deny
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
