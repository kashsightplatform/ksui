# KSUI prompt theme — JARVIS-blue 2-line minimalist
# Replaces powerlevel10k for KSUI users. Pure zsh, no external deps.
#
# Preview:
#   ~/ksui  main
#   ❯
#
# Right side shows last exit code (red if non-zero) + duration if >2s.

autoload -U colors && colors
setopt PROMPT_SUBST

# ── git branch (fast, no subshell per prompt unless in a repo) ─────────────
_ksui_git_branch() {
  local b
  b=$(command git symbolic-ref --short HEAD 2>/dev/null) || \
  b=$(command git rev-parse --short HEAD 2>/dev/null)
  [[ -n $b ]] && printf ' %%F{214}ue0a0 %s%%f' "$b"
}

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

zmodload zsh/datetime 2>/dev/null
autoload -U add-zsh-hook
add-zsh-hook preexec _ksui_timer_start
add-zsh-hook precmd  _ksui_timer_stop

_ksui_rprompt() {
  local out=""
  if (( ${_KSUI_LAST_STATUS:-0} != 0 )); then
    out+="%F{203}✖ ${_KSUI_LAST_STATUS}%f "
  fi
  if (( ${_KSUI_LAST_DUR:-0} > 2 )); then
    out+="%F{244}${_KSUI_LAST_DUR}s%f"
  fi
  printf '%s' "$out"
}

# ── prompt ────────────────────────────────────────────────────────────────
# line 1: cyan dir + orange git branch
# line 2: magenta prompt char (red if last command failed)
PROMPT=$'\n%F{51}%~%f$(_ksui_git_branch)\n%(?.%F{213}.%F{203})❯%f '
RPROMPT='$(_ksui_rprompt)'

# Transient prompt (collapses previous prompt to just ❯ for cleaner scrollback)
_ksui_set_transient() {
  PROMPT='%(?.%F{213}.%F{203})❯%f '
  zle && zle reset-prompt
}
# Run once after each accept-line — comment out if you prefer full history
# add-zsh-hook precmd _ksui_set_transient
