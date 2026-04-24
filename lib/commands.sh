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
  ${C_GREEN}motd${C_RESET}           Reprint the banner (logo + sysinfo + disk)
  ${C_GREEN}time${C_RESET} / ${C_GREEN}date${C_RESET}    Current date and time
  ${C_GREEN}ls${C_RESET} / ${C_GREEN}ll${C_RESET}       List files with icons
  ${C_GREEN}cd${C_RESET} <dir>       Change directory
  ${C_GREEN}clear${C_RESET} / ${C_GREEN}cls${C_RESET}   Clear screen
  ${C_GREEN}voice${C_RESET} on|off   Toggle JARVIS voice
  ${C_GREEN}theme${C_RESET} [name]   List / switch prompt theme
  ${C_GREEN}update${C_RESET}         git pull + re-run installer
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
  local topics=(programming science animals food coffee space "dad joke" music
                math cats dogs AI robots aliens pirates ninjas wizards)
  local t=${topics[RANDOM % ${#topics[@]}]}
  local nonce=$RANDOM
  printf "${C_YELLOW}😄${C_RESET} "
  tgpt "Tell me ONE fresh short clean genuinely funny joke about $t. Different from your last one. Just the joke, no preamble. [seed=$nonce]"
}

cmd::fact() {
  cmd::_need_tgpt || return 1
  local topics=(history biology physics space oceans animals "ancient civilizations"
                psychology geography chemistry technology music language food
                mathematics medicine sports "deep sea" insects)
  local t=${topics[RANDOM % ${#topics[@]}]}
  local nonce=$RANDOM
  printf "${C_CYAN}💡${C_RESET} "
  tgpt "Give me ONE surprising fun fact about $t in 1-2 sentences. Something most people don't know. No preamble. [seed=$nonce]"
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

cmd::update() {
  if [[ ! -d $KSUI_HOME/.git ]]; then
    ui::say_status ERR "Not a git install — cannot self-update."
    ui::say_status INFO "Re-run the installer manually to update."
    return 1
  fi
  ui::say_status INFO "Fetching latest from origin…"
  if git -C "$KSUI_HOME" pull --ff-only; then
    ui::say_status OK "KSUI is now up to date."
    if [[ -x $KSUI_HOME/install/install.sh ]]; then
      ui::say_status INFO "Re-running installer to refresh assets…"
      KSUI_REPO="$KSUI_HOME" KSUI_INSTALL_DIR="$KSUI_HOME" \
        bash "$KSUI_HOME/install/install.sh" || true
    fi
  else
    ui::say_status ERR "git pull failed — resolve conflicts and retry."
    return 1
  fi
}

cmd::theme() {
  local themes_dir="$KSUI_HOME/zsh/themes"
  local cfg="$HOME/.ksui/theme"
  local name="${1:-}"

  # list available themes
  local -a available=()
  if [[ -d $themes_dir ]]; then
    for f in "$themes_dir"/*.zsh-theme; do
      [[ -f $f ]] || continue
      available+=("$(basename "$f" .zsh-theme)")
    done
  fi

  if [[ -z $name ]]; then
    local current=""
    [[ -f $cfg ]] && current=$(cat "$cfg")
    printf "${C_CYAN}Available themes:${C_RESET}\n"
    for t in "${available[@]}"; do
      if [[ $t == "${current:-ksui}" ]]; then
        printf "  ${C_GREEN}●${C_RESET} %s ${C_DIM}(active)${C_RESET}\n" "$t"
      else
        printf "  ${C_DIM}○${C_RESET} %s\n" "$t"
      fi
    done
    printf "\n${C_DIM}Use: ksui theme <name>${C_RESET}\n"
    return 0
  fi

  # switch
  local chosen=""
  for t in "${available[@]}"; do
    [[ $t == "$name" ]] && chosen=$t && break
  done
  if [[ -z $chosen ]]; then
    ui::say_status ERR "Unknown theme: $name"
    ui::say_status INFO "Available: ${available[*]}"
    return 1
  fi
  mkdir -p "$(dirname "$cfg")"
  printf '%s\n' "$chosen" > "$cfg"
  ui::say_status OK "Theme set to: $chosen"
  ui::say_status INFO "Open a new shell (or run: exec zsh) to see it."
}
