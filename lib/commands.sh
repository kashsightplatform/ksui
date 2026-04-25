#!/data/data/com.termux/files/usr/bin/env bash
# KSUI — built-in commands

cmd::help() {
  cat <<EOF

${C_CYAN}${C_BOLD}KSUI Commands${C_RESET}
${C_GRAY}──────────────────────────────${C_RESET}
  ${C_GREEN}help${C_RESET}           Show this menu
  ${C_GREEN}about${C_RESET}          About the maker (Kashsight)
  ${C_GREEN}ask${C_RESET} <q...>     Ask KAI anything (uses tgpt)
  ${C_GREEN}joke${C_RESET}           Tell a joke (tgpt, random topic)
  ${C_GREEN}fact${C_RESET}           Random fun fact (tgpt, random topic)
  ${C_GREEN}meme${C_RESET}           Fetch a random meme
  ${C_GREEN}news${C_RESET}           Top headlines (Hacker News)
  ${C_GREEN}crypto${C_RESET} [coin]  Crypto price (CoinGecko)
  ${C_GREEN}ip${C_RESET}             Public IP + geo (ipinfo.io)
  ${C_GREEN}define${C_RESET} <word>  Dictionary lookup
  ${C_GREEN}weather${C_RESET} [city] Current weather (wttr.in)
  ${C_GREEN}sysinfo${C_RESET}        System info (neofetch if available)
  ${C_GREEN}qr${C_RESET} <text>      Render a QR code in the terminal
  ${C_GREEN}note${C_RESET} <text>    Append a timestamped note
  ${C_GREEN}notes${C_RESET}          Show all notes
  ${C_GREEN}todo${C_RESET} [text]    Add/list todo items (todo done N to check off)
  ${C_GREEN}timer${C_RESET} <min>    Pomodoro timer with voice alert
  ${C_GREEN}doctor${C_RESET}         Audit optional deps + KSUI health
  ${C_GREEN}motd${C_RESET}           Reprint the banner
  ${C_GREEN}banner${C_RESET} <text>   Build a custom banner (a-z/0-9 only)
  ${C_GREEN}time${C_RESET} / ${C_GREEN}date${C_RESET}    Current date and time
  ${C_GREEN}ls${C_RESET} / ${C_GREEN}ll${C_RESET}       List files with icons
  ${C_GREEN}cd${C_RESET} <dir>       Change directory
  ${C_GREEN}clear${C_RESET} / ${C_GREEN}cls${C_RESET}   Clear screen
  ${C_GREEN}voice${C_RESET} on|off   Toggle KAI voice
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

cmd::_need_curl() {
  if ! command -v curl >/dev/null 2>&1; then
    ui::say_status ERR "curl is required for this command"
    return 1
  fi
}

cmd::ask() {
  cmd::_need_tgpt || return 1
  local q="$*"
  [[ -z $q ]] && { ui::say_status WARN "Usage: ask <question>"; return 1; }
  printf "${C_BLUE}🤖 KAI:${C_RESET}\n"
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
  cmd::_need_curl || return 1
  curl -fsSL --max-time 10 "https://wttr.in/${city// /+}?format=v2&m" 2>/dev/null || \
    ui::say_status ERR "Weather service unreachable"
}

cmd::sysinfo() {
  if command -v neofetch >/dev/null 2>&1; then
    neofetch
  else
    printf "User     : %s\n" "${KSUI_USER:-$USER}"
    printf "Shell    : %s\n" "$SHELL"
    printf "Host     : %s\n" "$(uname -n)"
    printf "Kernel   : %s\n" "$(uname -sr)"
    printf "Uptime   : %s\n" "$(uptime -p 2>/dev/null || uptime)"
  fi
}

# ── news (Hacker News top 5) ─────────────────────────────────────────────
cmd::news() {
  cmd::_need_curl || return 1
  printf "${C_CYAN}${C_BOLD}📰 Top headlines${C_RESET}  ${C_DIM}(news.ycombinator.com)${C_RESET}\n"
  local ids
  ids=$(curl -fsSL --max-time 8 \
    "https://hacker-news.firebaseio.com/v0/topstories.json" 2>/dev/null \
    | tr ',' '\n' | tr -d '[]' | head -n 8)
  [[ -z $ids ]] && { ui::say_status ERR "News service unreachable"; return 1; }
  local n=0
  while read -r id; do
    [[ -z $id ]] && continue
    local title url
    title=$(curl -fsSL --max-time 5 \
      "https://hacker-news.firebaseio.com/v0/item/$id.json" 2>/dev/null \
      | grep -oE '"title":"[^"]+"' | head -n1 | cut -d'"' -f4)
    url=$(curl -fsSL --max-time 5 \
      "https://hacker-news.firebaseio.com/v0/item/$id.json" 2>/dev/null \
      | grep -oE '"url":"[^"]+"' | head -n1 | cut -d'"' -f4)
    [[ -z $title ]] && continue
    n=$((n+1))
    printf "  ${C_YELLOW}%d.${C_RESET} %s\n" "$n" "$title"
    [[ -n $url ]] && printf "     ${C_DIM}%s${C_RESET}\n" "$url"
    (( n >= 5 )) && break
  done <<< "$ids"
}

# ── crypto (CoinGecko simple-price) ──────────────────────────────────────
cmd::crypto() {
  cmd::_need_curl || return 1
  local coin="${1:-bitcoin}"
  coin=${coin,,}
  # a few friendly aliases
  case $coin in
    btc) coin=bitcoin;;
    eth) coin=ethereum;;
    sol) coin=solana;;
    ada) coin=cardano;;
    doge) coin=dogecoin;;
    bnb) coin=binancecoin;;
    xrp) coin=ripple;;
    ltc) coin=litecoin;;
  esac
  local data
  data=$(curl -fsSL --max-time 8 \
    "https://api.coingecko.com/api/v3/simple/price?ids=$coin&vs_currencies=usd,kes&include_24hr_change=true" 2>/dev/null)
  if [[ -z $data || $data == "{}" ]]; then
    ui::say_status ERR "Unknown coin: $coin"
    ui::say_status INFO "Try: btc, eth, sol, doge, or a coingecko id"
    return 1
  fi
  local usd kes chg
  usd=$(printf '%s' "$data" | grep -oE '"usd":[0-9.eE+-]+' | head -n1 | cut -d: -f2)
  kes=$(printf '%s' "$data" | grep -oE '"kes":[0-9.eE+-]+' | head -n1 | cut -d: -f2)
  chg=$(printf '%s' "$data" | grep -oE '"usd_24h_change":[0-9.eE+-]+' | head -n1 | cut -d: -f2)
  local arrow color
  if [[ ${chg:-0} == -* ]]; then arrow="▼"; color=$C_RED; else arrow="▲"; color=$C_GREEN; fi
  printf "${C_CYAN}₿  %s${C_RESET}\n" "$coin"
  printf "   USD : ${C_BOLD}\$%s${C_RESET}  ${color}%s %s%%${C_RESET}\n" \
    "${usd:-?}" "$arrow" "$(printf '%.2f' "${chg:-0}" 2>/dev/null || echo "${chg}")"
  [[ -n $kes ]] && printf "   KES : ${C_BOLD}KSh %s${C_RESET}\n" "$kes"
}

# ── ip (public IP + geo) ─────────────────────────────────────────────────
cmd::ip() {
  cmd::_need_curl || return 1
  local data
  data=$(curl -fsSL --max-time 6 "https://ipinfo.io/json" 2>/dev/null)
  [[ -z $data ]] && { ui::say_status ERR "ipinfo.io unreachable"; return 1; }
  local ip city region country org
  ip=$(printf '%s' "$data" | grep -oE '"ip":"[^"]+"' | cut -d'"' -f4)
  city=$(printf '%s' "$data" | grep -oE '"city":"[^"]+"' | cut -d'"' -f4)
  region=$(printf '%s' "$data" | grep -oE '"region":"[^"]+"' | cut -d'"' -f4)
  country=$(printf '%s' "$data" | grep -oE '"country":"[^"]+"' | cut -d'"' -f4)
  org=$(printf '%s' "$data" | grep -oE '"org":"[^"]+"' | cut -d'"' -f4)
  printf "${C_CYAN}🌐 Public IP${C_RESET}\n"
  printf "   IP       : ${C_BOLD}%s${C_RESET}\n" "${ip:-?}"
  printf "   Location : %s, %s, %s\n" "${city:-?}" "${region:-?}" "${country:-?}"
  [[ -n $org ]] && printf "   Org      : ${C_DIM}%s${C_RESET}\n" "$org"
}

# ── define (dictionaryapi.dev) ───────────────────────────────────────────
cmd::define() {
  cmd::_need_curl || return 1
  local word="${1:-}"
  [[ -z $word ]] && { ui::say_status WARN "Usage: define <word>"; return 1; }
  local data
  data=$(curl -fsSL --max-time 6 \
    "https://api.dictionaryapi.dev/api/v2/entries/en/$word" 2>/dev/null)
  if [[ -z $data || $data == *'"title":"No Definitions Found"'* ]]; then
    ui::say_status ERR "No definition found for: $word"
    return 1
  fi
  printf "${C_CYAN}${C_BOLD}📖 %s${C_RESET}\n" "$word"
  # pull a couple of definitions with crude grep (no jq dependency)
  printf '%s' "$data" \
    | grep -oE '"partOfSpeech":"[^"]+"|"definition":"[^"]+"' \
    | head -n 8 \
    | awk -F'"' '
        /partOfSpeech/ { printf "\n  \033[38;5;215m(%s)\033[0m\n", $4; next }
        /definition/   { printf "    • %s\n", $4 }'
}

# ── qr ───────────────────────────────────────────────────────────────────
cmd::qr() {
  if ! command -v qrencode >/dev/null 2>&1; then
    ui::say_status ERR "qrencode not installed. Run: pkg install qrencode"
    return 1
  fi
  local text="$*"
  [[ -z $text ]] && { ui::say_status WARN "Usage: qr <text or URL>"; return 1; }
  qrencode -t ANSIUTF8 "$text"
}

# ── note / notes ─────────────────────────────────────────────────────────
cmd::note() {
  local f="$HOME/.ksui/notes.md"
  mkdir -p "$(dirname "$f")"
  local text="$*"
  if [[ -z $text ]]; then
    ui::say_status WARN "Usage: note <text>  (use 'notes' to list)"
    return 1
  fi
  printf '- [%s] %s\n' "$(date '+%Y-%m-%d %H:%M')" "$text" >> "$f"
  ui::say_status OK "Noted."
}

cmd::notes() {
  local f="$HOME/.ksui/notes.md"
  if [[ ! -s $f ]]; then
    ui::say_status INFO "No notes yet. Add with: note <text>"
    return 0
  fi
  printf "${C_CYAN}${C_BOLD}📝 Your notes${C_RESET}  ${C_DIM}(%s)${C_RESET}\n" "$f"
  cat "$f"
}

# ── todo ─────────────────────────────────────────────────────────────────
cmd::todo() {
  local f="$HOME/.ksui/todo.md"
  mkdir -p "$(dirname "$f")"
  touch "$f"
  local sub="${1:-}"
  case "$sub" in
    done|do)
      local n="${2:-}"
      [[ -z $n ]] && { ui::say_status WARN "Usage: todo done <number>"; return 1; }
      awk -v n="$n" '
        /^- \[ \]/ { i++; if (i==n) { sub(/\[ \]/, "[x]") } }
        { print }
      ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
      ui::say_status OK "Marked #$n done."
      cmd::todo   # reprint
      ;;
    rm|remove)
      local n="${2:-}"
      [[ -z $n ]] && { ui::say_status WARN "Usage: todo rm <number>"; return 1; }
      awk -v n="$n" '
        /^- \[/ { i++; if (i==n) next }
        { print }
      ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
      ui::say_status OK "Removed #$n."
      cmd::todo
      ;;
    clear)
      : > "$f"
      ui::say_status OK "Todo list cleared."
      ;;
    "")
      if [[ ! -s $f ]]; then
        ui::say_status INFO "Empty. Add with: todo <text>   |  Check off: todo done <n>"
        return 0
      fi
      printf "${C_CYAN}${C_BOLD}✅ Todo${C_RESET}\n"
      awk '
        /^- \[/ {
          i++
          line=$0
          if (line ~ /\[x\]/) {
            gsub(/\[x\]/, "\033[38;5;120m[✓]\033[0m", line)
            printf "  \033[2m%2d. %s\033[0m\n", i, line
          } else {
            gsub(/\[ \]/, "\033[38;5;221m[ ]\033[0m", line)
            printf "  %2d. %s\n", i, line
          }
        }
      ' "$f"
      ;;
    *)
      printf '- [ ] %s\n' "$*" >> "$f"
      ui::say_status OK "Added."
      ;;
  esac
}

# ── timer (pomodoro) ─────────────────────────────────────────────────────
cmd::timer() {
  local mins="${1:-25}"
  if ! [[ $mins =~ ^[0-9]+$ ]] || (( mins <= 0 )); then
    ui::say_status WARN "Usage: timer <minutes>"; return 1
  fi
  local secs=$(( mins * 60 ))
  local end=$(( $(date +%s) + secs ))
  ui::say_status INFO "Timer: ${mins}m. Ctrl-C to abort."
  trap 'printf "\n"; ui::say_status WARN "Timer aborted."; trap - INT; return 130' INT
  while (( $(date +%s) < end )); do
    local left=$(( end - $(date +%s) ))
    printf "\r  ${C_CYAN}⏳${C_RESET} %02d:%02d remaining " $(( left / 60 )) $(( left % 60 ))
    sleep 1
  done
  trap - INT
  printf "\r  ${C_GREEN}✔${C_RESET} Timer done!                 \n"
  if command -v voice::say >/dev/null 2>&1; then
    voice::say "Timer complete, ${KSUI_USER:-sir}. ${mins} minutes elapsed."
  fi
  if command -v sound::chime >/dev/null 2>&1; then sound::chime; fi
  if command -v termux-notification >/dev/null 2>&1; then
    termux-notification -t "KSUI timer" -c "${mins}m elapsed" 2>/dev/null || true
  fi
}

# ── doctor (environment audit) ───────────────────────────────────────────
cmd::doctor() {
  printf "${C_CYAN}${C_BOLD}🩺 KSUI Doctor${C_RESET}\n"
  printf "${C_GRAY}────────────────────────────────${C_RESET}\n"
  _ksui_doctor_check() {
    local label=$1 bin=$2 required=${3:-optional}
    if command -v "$bin" >/dev/null 2>&1; then
      printf "  ${C_GREEN}✔${C_RESET} %-22s ${C_DIM}(%s)${C_RESET}\n" "$label" "$(command -v "$bin")"
    else
      if [[ $required == required ]]; then
        printf "  ${C_RED}✖${C_RESET} %-22s ${C_RED}MISSING (required)${C_RESET}\n" "$label"
      else
        printf "  ${C_YELLOW}○${C_RESET} %-22s ${C_DIM}not installed${C_RESET}\n" "$label"
      fi
    fi
  }
  _ksui_doctor_check "bash"      bash    required
  _ksui_doctor_check "zsh"       zsh     required
  _ksui_doctor_check "git"       git     required
  _ksui_doctor_check "curl"      curl    required
  _ksui_doctor_check "lsd"       lsd
  _ksui_doctor_check "tgpt"      tgpt
  _ksui_doctor_check "fzf"       fzf
  _ksui_doctor_check "fd"        fd
  _ksui_doctor_check "espeak"    espeak
  _ksui_doctor_check "sox"       play
  _ksui_doctor_check "qrencode"  qrencode
  _ksui_doctor_check "neofetch"  neofetch
  _ksui_doctor_check "openssl"   openssl
  _ksui_doctor_check "termux-api" termux-notification
  printf "${C_GRAY}────────────────────────────────${C_RESET}\n"
  # KSUI installation checks
  local ok=1
  for f in "$KSUI_HOME/bin/ksui" "$KSUI_HOME/motd/init.sh" "$KSUI_HOME/lib/auth.sh"; do
    if [[ -e $f ]]; then
      printf "  ${C_GREEN}✔${C_RESET} %s\n" "${f#$KSUI_HOME/}"
    else
      printf "  ${C_RED}✖${C_RESET} %s ${C_RED}missing${C_RESET}\n" "${f#$KSUI_HOME/}"
      ok=0
    fi
  done
  if (( ok )); then
    ui::say_status OK "KSUI install looks healthy."
  else
    ui::say_status ERR "Some KSUI files are missing — try: ksui update"
  fi
  unset -f _ksui_doctor_check
}

cmd::voice_toggle() {
  local cfg="$HOME/.ksui/voice"
  case "${1:-}" in
    on)
      export KSUI_VOICE=1
      mkdir -p "$(dirname "$cfg")"
      printf '1\n' > "$cfg"
      ui::say_status OK "Voice enabled (saved)"
      voice::say "Voice online."
      ;;
    off)
      export KSUI_VOICE=0
      mkdir -p "$(dirname "$cfg")"
      printf '0\n' > "$cfg"
      ui::say_status OK "Voice muted (saved)"
      ;;
    *)
      ui::say_status INFO "Voice is currently: $([[ ${KSUI_VOICE:-1} -eq 1 ]] && echo on || echo off)"
      ;;
  esac
}

cmd::banner() {
  local text="$*"
  if [[ -z $text ]]; then
    ui::say_status WARN "Usage: banner <text>   (letters/digits only, no spaces)"
    return 1
  fi
  if ! command -v banner::build >/dev/null 2>&1; then
    [[ -f "$KSUI_HOME/lib/banner.sh" ]] && source "$KSUI_HOME/lib/banner.sh"
  fi
  banner::build "$text"
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
