#!/data/data/com.termux/files/usr/bin/env bash
# KSUI — built-in commands

cmd::help() {
  cat <<EOF

${C_CYAN}${C_BOLD}KSUI Commands${C_RESET}
${C_GRAY}──────────────────────────────${C_RESET}
  ${C_GREEN}help${C_RESET}           Show this menu
  ${C_GREEN}about${C_RESET}          About the maker (Kashsight)
  ${C_GREEN}ask${C_RESET} <q...>     Ask JARVIS anything (uses tgpt)
  ${C_GREEN}joke${C_RESET}           Tell a joke (tgpt)
  ${C_GREEN}meme${C_RESET}           Fetch a random meme
  ${C_GREEN}fact${C_RESET}           Random fun fact (tgpt)
  ${C_GREEN}weather${C_RESET} [city] Current weather (wttr.in)
  ${C_GREEN}sysinfo${C_RESET}        System info (neofetch if available)
  ${C_GREEN}ls${C_RESET} / ${C_GREEN}ll${C_RESET}       List files with icons
  ${C_GREEN}cd${C_RESET} <dir>       Change directory
  ${C_GREEN}clear${C_RESET} / ${C_GREEN}cls${C_RESET}   Clear screen
  ${C_GREEN}voice${C_RESET} on|off   Toggle JARVIS voice
  ${C_GREEN}whoami${C_RESET}         Show logged-in user
  ${C_GREEN}reset-auth${C_RESET}     Reset username/password
  ${C_GREEN}exit${C_RESET} / ${C_GREEN}quit${C_RESET}   Shut down KSUI
${C_GRAY}──────────────────────────────${C_RESET}
Any other input is passed to your shell.

EOF
}

cmd::about() {
  ui::banner
  ui::maker_intro
}

cmd::_need_tgpt() {
  if ! command -v tgpt >/dev/null 2>&1; then
    ui::say_status ERR "tgpt not installed. Run: pkg install tgpt  (or see README)"
    return 1
  fi
}

cmd::ask() {
  cmd::_need_tgpt || return 1
  local q="$*"
  [[ -z $q ]] && { ui::say_status WARN "Usage: ask <question>"; return 1; }
  printf "${C_BLUE}🤖 JARVIS:${C_RESET}\n"
  tgpt "$q"
}

cmd::joke() {
  cmd::_need_tgpt || return 1
  printf "${C_YELLOW}😄${C_RESET} "
  tgpt "Tell me one short, clean, genuinely funny joke. Just the joke, no preamble."
}

cmd::fact() {
  cmd::_need_tgpt || return 1
  printf "${C_CYAN}💡${C_RESET} "
  tgpt "Give me one surprising fun fact in 1-2 sentences. No preamble."
}

cmd::meme() {
  local url=""
  if command -v curl >/dev/null 2>&1; then
    url=$(curl -fsSL --max-time 5 https://meme-api.com/gimme 2>/dev/null | \
          grep -oE '"url":"[^"]+"' | head -n1 | cut -d'"' -f4)
  fi
  # Fallback to bundled meme list
  if [[ -z $url && -f ${KSUI_HOME}/assets/memes.txt ]]; then
    url=$(shuf -n1 "${KSUI_HOME}/assets/memes.txt" 2>/dev/null || \
          awk 'NR==int(rand()*NR)+1' "${KSUI_HOME}/assets/memes.txt")
    ui::say_status INFO "Using bundled meme (API unreachable)"
  fi
  if [[ -z $url ]]; then
    ui::say_status ERR "No meme available"; return 1
  fi
  printf "${C_MAGENTA}🖼  Meme:${C_RESET} %s\n" "$url"
  if command -v termux-open-url >/dev/null 2>&1; then
    termux-open-url "$url"
  fi
}

cmd::weather() {
  local city="${*:-}"
  curl -fsSL "https://wttr.in/${city// /+}?format=v2&m" 2>/dev/null || \
    ui::say_status ERR "Weather service unreachable"
}

cmd::sysinfo() {
  if command -v neofetch >/dev/null 2>&1; then
    neofetch
  else
    printf "User     : %s\n" "$KSUI_USER"
    printf "Shell    : %s\n" "$SHELL"
    printf "Host     : %s\n" "$(uname -n)"
    printf "Kernel   : %s\n" "$(uname -sr)"
    printf "Uptime   : %s\n" "$(uptime -p 2>/dev/null || uptime)"
  fi
}

cmd::voice_toggle() {
  case "${1:-}" in
    on)  export KSUI_VOICE=1; ui::say_status OK "Voice enabled"; voice::say "Voice online.";;
    off) export KSUI_VOICE=0; ui::say_status OK "Voice muted";;
    *)   ui::say_status INFO "Voice is currently: $([[ ${KSUI_VOICE:-1} -eq 1 ]] && echo on || echo off)";;
  esac
}

cmd::whoami() {
  printf "  ${C_CYAN}%s${C_RESET} (KSUI session)\n" "${KSUI_USER:-unknown}"
}
