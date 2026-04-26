# KSH autosuggestions — minimal ghost-text suggestion (no popup, no fzf).
#
# Shows the most recent matching history command as greyed-out text after
# the cursor. Updates on every keystroke.
#   →  or Ctrl+F  : accept full suggestion
#   Alt+→ / M-f   : accept just the next word

: ${KSH_AUTOSUGGEST_COLOR:='fg=244'}

typeset -g _ksh_sugg=""
# Resolve awk to absolute path once. If awk is missing (stock Termux
# without gawk), suggestions silently no-op instead of spamming
# command-not-found on every keystroke.
typeset -g _KSH_SUGG_AWK="${commands[awk]:-$(command -v awk 2>/dev/null)}"

_ksh_suggest() {
  _ksh_sugg=""
  POSTDISPLAY=""
  region_highlight=()
  [[ -z $BUFFER ]] && return
  [[ -x $_KSH_SUGG_AWK ]] || return

  local match
  match=$(fc -ln 1 2>/dev/null | "$_KSH_SUGG_AWK" -v q="$BUFFER" '
    {
      line=$0
      if (index(line,q)==1 && length(line)>length(q)) {
        print line
        exit
      }
    }
  ' 2>/dev/null)

  if [[ -n $match ]]; then
    _ksh_sugg="${match#$BUFFER}"
    POSTDISPLAY="$_ksh_sugg"
    region_highlight=("${#BUFFER} $((${#BUFFER}+${#POSTDISPLAY})) ${KSH_AUTOSUGGEST_COLOR}")
  fi
}

_ksh_accept() {
  if [[ -n $POSTDISPLAY ]]; then
    BUFFER="$BUFFER$POSTDISPLAY"
    CURSOR=${#BUFFER}
    POSTDISPLAY=""
    region_highlight=()
  else
    zle .forward-char 2>/dev/null || zle .end-of-line
  fi
}

_ksh_accept_word() {
  if [[ -n $POSTDISPLAY ]]; then
    local word="${POSTDISPLAY%% *} "
    BUFFER="$BUFFER$word"
    CURSOR=${#BUFFER}
    POSTDISPLAY="${POSTDISPLAY#$word}"
    region_highlight=("${#BUFFER} $((${#BUFFER}+${#POSTDISPLAY})) ${KSH_AUTOSUGGEST_COLOR}")
  else
    zle .forward-word 2>/dev/null
  fi
}

zle -N _ksh_accept
zle -N _ksh_accept_word

# Recompute after each self-insert / backspace.
_ksh_self_insert() { zle .self-insert; _ksh_suggest; }
_ksh_backspace()   { zle .backward-delete-char; _ksh_suggest; }
zle -N self-insert _ksh_self_insert
zle -N backward-delete-char _ksh_backspace

# Right arrow and Ctrl-F accept; Alt-F accepts one word.
bindkey '^[[C'  _ksh_accept
bindkey '^F'    _ksh_accept
bindkey '^[f'   _ksh_accept_word
