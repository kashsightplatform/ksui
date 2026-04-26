# KSUI prompt theme: forest — dark green, two-line, no external deps
#
# Layout matches ksui.zsh-theme but with a forest-green palette.

autoload -U colors && colors
autoload -U add-zsh-hook
setopt PROMPT_SUBST

zmodload zsh/datetime 2>/dev/null

_ksui_t0=0
_ksui_timer_start() { _ksui_t0=$EPOCHSECONDS; }
_ksui_timer_stop()  {
  _KSUI_LAST_STATUS=$?
  if (( _ksui_t0 )); then
    _KSUI_LAST_DUR=$(( EPOCHSECONDS - _ksui_t0 ))
    _ksui_t0=0
  else
    _KSUI_LAST_DUR=0
  fi
}
add-zsh-hook preexec _ksui_timer_start
add-zsh-hook precmd  _ksui_timer_stop

_ksui_git() {
  command -v git >/dev/null 2>&1 || return
  local b
  b=$(command git symbolic-ref --short HEAD 2>/dev/null) \
    || b=$(command git rev-parse --short HEAD 2>/dev/null) \
    || return
  local dirty
  if [[ -n $(command git status --porcelain 2>/dev/null) ]]; then
    dirty='%F{220}±%f'
  else
    dirty='%F{34}✓%f'
  fi
  printf ' %%F{34}(%s)%s' "$b" "$dirty"
}

_ksui_rp() {
  local out=""
  (( ${_KSUI_LAST_DUR:-0} > 1 )) && out+="%F{106}⏱ ${_KSUI_LAST_DUR}s%f  "
  (( ${_KSUI_LAST_STATUS:-0} != 0 )) && out+="%F{203}✖ ${_KSUI_LAST_STATUS}%f"
  printf '%s' "$out"
}

# Dark forest-green path, brighter green prompt char.
PROMPT=$'\n%F{28}%~%f$(_ksui_git)\n%(?.%F{34}.%F{203})❯%f '
RPROMPT='$(_ksui_rp)%F{244} %D{%H:%M:%S}%f'
