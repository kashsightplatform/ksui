# KSUI prompt theme — KAI-blue, two-line, no external deps
#
# Layout:
#   ~/path/to/dir  (git-branch±)                              19:33:24
#   ❯ command...                                  ⏱ 2s  ✖ 1
#
#   - cwd in cyan, git branch with dirty marker in green/yellow
#   - clock on right
#   - second line: prompt char (magenta on success, red on failure)
#   - rprompt on second line shows last command duration + exit code

autoload -U colors && colors
autoload -U add-zsh-hook
setopt PROMPT_SUBST

zmodload zsh/datetime 2>/dev/null

# ── command timing ────────────────────────────────────────────────────────
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

# ── git status (no external deps beyond `git` itself) ─────────────────────
_ksui_git() {
  command -v git >/dev/null 2>&1 || return
  local b dirty
  b=$(command git symbolic-ref --short HEAD 2>/dev/null) \
    || b=$(command git rev-parse --short HEAD 2>/dev/null) \
    || return
  # `--porcelain` is fast and silent; any output = dirty
  if [[ -n $(command git status --porcelain 2>/dev/null) ]]; then
    dirty='%F{221}±%f'
  else
    dirty='%F{120}✓%f'
  fi
  printf ' %%F{120}(%s)%s' "$b" "$dirty"
}

# ── right-prompt (shown on the prompt-char line) ──────────────────────────
_ksui_rp() {
  local out=""
  (( ${_KSUI_LAST_DUR:-0} > 1 )) && \
    out+="%F{93}⏱ ${_KSUI_LAST_DUR}s%f  "
  (( ${_KSUI_LAST_STATUS:-0} != 0 )) && \
    out+="%F{203}✖ ${_KSUI_LAST_STATUS}%f"
  printf '%s' "$out"
}

# ── prompt ────────────────────────────────────────────────────────────────
# Line 1: cwd (+ git) on the left, clock on the right
# Line 2: prompt char (cyan ❯, magenta if last command failed)
PROMPT=$'\n%F{51}%~%f$(_ksui_git)\n%(?.%F{51}.%F{203})❯%f '
RPROMPT='$(_ksui_rp)%F{244} %D{%H:%M:%S}%f'
