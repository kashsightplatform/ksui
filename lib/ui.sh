#!/data/data/com.termux/files/usr/bin/env bash
# KSUI — UI helpers (colors, banners, ls wrappers)

# --- colors ---
export C_RESET=$'\033[0m'
export C_BOLD=$'\033[1m'
export C_DIM=$'\033[2m'
export C_RED=$'\033[38;5;203m'
export C_GREEN=$'\033[38;5;120m'
export C_YELLOW=$'\033[38;5;221m'
export C_BLUE=$'\033[38;5;75m'
export C_CYAN=$'\033[38;5;51m'
export C_MAGENTA=$'\033[38;5;213m'
export C_ORANGE=$'\033[38;5;215m'
export C_GRAY=$'\033[38;5;245m'

ui::hr() {
  local w=${COLUMNS:-$(tput cols 2>/dev/null || echo 60)}
  printf "${C_DIM}%${w}s${C_RESET}\n" "" | tr ' ' '─'
}

ui::banner() {
  # Full motd-style splash: big KASHSIGHT logo + sysinfo + disk panel
  local motd="${KSUI_HOME}/motd/init.sh"
  if [[ -x $motd ]]; then
    "$motd"
  else
    local file="${KSUI_HOME}/assets/banner.txt"
    [[ -f $file ]] && printf "${C_CYAN}%s${C_RESET}\n" "$(cat "$file")"
  fi
}

ui::small_banner() {
  # Compact banner for status lines (post-login, etc)
  local file="${KSUI_HOME}/assets/banner.txt"
  [[ -f $file ]] && printf "${C_CYAN}%s${C_RESET}\n" "$(cat "$file")"
}

ui::maker_intro() {
  cat <<EOF

${C_ORANGE}${C_BOLD}⚡ Made by KASHSIGHT ⚡${C_RESET}
${C_GRAY}────────────────────────${C_RESET}
  ${C_CYAN}🎬 YouTube  ${C_RESET} youtube.com/@kashsight
  ${C_MAGENTA}📸 Instagram${C_RESET} instagram.com/kashsight
  ${C_BLUE}📘 Facebook ${C_RESET} facebook.com/kashsight
  ${C_GREEN}💻 GitHub   ${C_RESET} github.com/kashsight
${C_GRAY}────────────────────────${C_RESET}
EOF
}

ui::say_status() {
  # ui::say_status OK "message"
  local tag=$1; shift
  case $tag in
    OK)   printf "  ${C_GREEN}✔${C_RESET} %s\n" "$*";;
    WARN) printf "  ${C_YELLOW}⚠${C_RESET} %s\n" "$*";;
    ERR)  printf "  ${C_RED}✖${C_RESET} %s\n" "$*";;
    INFO) printf "  ${C_BLUE}ℹ${C_RESET} %s\n" "$*";;
    *)    printf "  • %s\n" "$*";;
  esac
}

ui::prompt_char() {
  printf "${C_MAGENTA}❯${C_RESET} "
}

# ls with icons (matches user's Termux setup: lsd + FiraCode)
ui::ls() {
  if command -v lsd >/dev/null 2>&1; then
    lsd --icon=always --icon-theme=unicode --group-dirs=first "$@"
  else
    ls --color=auto "$@"
  fi
}

ui::ll() {
  if command -v lsd >/dev/null 2>&1; then
    lsd -l --icon=always --icon-theme=unicode --group-dirs=first "$@"
  else
    ls -l --color=auto "$@"
  fi
}
