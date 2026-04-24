#!/data/data/com.termux/files/usr/bin/env bash
# KSUI — sound fx (sox-synthesized, no binary assets needed)
# Uses `play` (sox). Silent fallback if sox isn't installed.

sound::_play() {
  [[ ${KSUI_SOUNDS:-1} -eq 0 ]] && return 0
  command -v play >/dev/null 2>&1 || return 0
  play -nq -t alsa "$@" 2>/dev/null &
}

# Short rising beep — boot / step
sound::beep() {
  sound::_play synth 0.05 sine 880 vol 0.25
}

# Double-beep — success/access granted
sound::chime() {
  sound::_play synth 0.08 sine 880 : synth 0.08 sine 1320 vol 0.25
}

# Low thud — error / denied
sound::deny() {
  sound::_play synth 0.25 sine 160 vol 0.3
}

# Sweep up — power on
sound::power_on() {
  sound::_play synth 0.4 sine 200-1400 vol 0.25
}

# Sweep down — power off
sound::power_off() {
  sound::_play synth 0.4 sine 1400-200 vol 0.25
}
