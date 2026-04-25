# KSUI prompt theme — KAI-blue, cwd left, clock right
#
# Preview:
#   ~                                                   19:33:24
#   ❯

autoload -U colors && colors
setopt PROMPT_SUBST

zmodload zsh/datetime 2>/dev/null

# ── command timing ─────────────────────────────────────────────────────────
_ksui_timer_start() { _KSUI_T0=$EPOCHSECONDS; }
_ksui_timer_stop()  {
  _KSUI_LAST_STATUS=$?
  if [[ -n ${_KSUI_T0:-} ]]; then
    _KSUI_LAST_DUR=$(( EPOCHSECONDS - _KSUI_T0 ))
    unset _KSUI_T0
  else
    _KSUI_LAST_DUR=0
  fi
}
autoload -U add-zsh-hook
add-zsh-hook preexec _ksui_timer_start
add-zsh-hook precmd  _ksui_timer_stop

# ── prompt ────────────────────────────────────────────────────────────────
# line 1: cyan cwd on the left, clock on the right
# line 2: magenta prompt char (red if last command failed)
PROMPT=$'\n%F{51}%~%f\n%(?.%F{213}.%F{203})❯%f '
RPROMPT='%F{244}%D{%H:%M:%S}%f'

# Transient prompt (collapses previous prompt to just ❯ for cleaner scrollback)
_ksui_set_transient() {
  PROMPT='%(?.%F{213}.%F{203})❯%f '
  zle && zle reset-prompt
}
# Run once after each accept-line — comment out if you prefer full history
# add-zsh-hook precmd _ksui_set_transient
