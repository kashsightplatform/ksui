# KSUI cyberpunk theme — magenta/green neon
autoload -U colors && colors
setopt PROMPT_SUBST

_cyber_git() {
  local b
  b=$(command git symbolic-ref --short HEAD 2>/dev/null) || return
  printf ' %%F{46}[%s]%%f' "$b"
}

zmodload zsh/datetime 2>/dev/null
autoload -U add-zsh-hook
_cyber_t0=0
_cyber_start() { _cyber_t0=$EPOCHSECONDS; }
_cyber_stop()  {
  _cyber_last_status=$?
  (( _cyber_t0 )) && _cyber_last_dur=$(( EPOCHSECONDS - _cyber_t0 )) || _cyber_last_dur=0
  _cyber_t0=0
}
add-zsh-hook preexec _cyber_start
add-zsh-hook precmd  _cyber_stop

_cyber_rp() {
  local out=""
  (( ${_cyber_last_status:-0} != 0 )) && out+="%F{201}ERR:${_cyber_last_status}%f "
  (( ${_cyber_last_dur:-0} > 1 )) && out+="%F{93}${_cyber_last_dur}s%f"
  printf '%s' "$out"
}

PROMPT=$'\n%F{201}┌──%f%F{51}[%n@%m]%f%F{201}─%f%F{213}[%~]%f$(_cyber_git)\n%F{201}└─%f%(?.%F{46}.%F{196})▶%f '
RPROMPT='$(_cyber_rp)'
