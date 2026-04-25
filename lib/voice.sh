#!/data/data/com.termux/files/usr/bin/env bash
# KSUI — KAI voice (espeak preferred, festival fallback, termux-tts last)

voice::available() {
  command -v espeak >/dev/null 2>&1 || \
  command -v festival >/dev/null 2>&1 || \
  command -v termux-tts-speak >/dev/null 2>&1
}

voice::say() {
  local msg="$*"
  [[ -z $msg ]] && return 0
  [[ ${KSUI_VOICE:-1} -eq 0 ]] && return 0

  if command -v espeak >/dev/null 2>&1; then
    # Deep slow KAI-ish voice
    espeak -v en-gb -s 150 -p 40 -a 180 "$msg" 2>/dev/null &
  elif command -v festival >/dev/null 2>&1; then
    echo "$msg" | festival --tts 2>/dev/null &
  elif command -v termux-tts-speak >/dev/null 2>&1; then
    termux-tts-speak -l en -r 0.9 -p 0.9 "$msg" 2>/dev/null &
  fi
}

voice::greet() {
  local hour=$(date +%H)
  local user=${KSUI_USER:-sir}
  local greeting="Good evening"
  if   (( hour < 12 )); then greeting="Good morning"
  elif (( hour < 18 )); then greeting="Good afternoon"
  fi
  voice::say "$greeting, $user. All systems are online. How may I assist you today?"
}

voice::bye() {
  voice::say "Powering down. Goodbye, ${KSUI_USER:-sir}."
}
