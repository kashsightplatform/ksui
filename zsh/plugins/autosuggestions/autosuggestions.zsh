# KSH autosuggestions — minimal original implementation
# Shows greyed-out history-based suggestion after cursor.
# Accept full suggestion: →  (or Ctrl+F)
# Accept next word      : Alt+→  (or Alt+F)

: ${KSH_AUTOSUGGEST_COLOR:='fg=244'}
: ${KSH_AUTOSUGGEST_STRATEGY:=history}

typeset -g _ksh_sugg=""

_ksh_suggest() {
  _ksh_sugg=""
  [[ -z $BUFFER ]] && { POSTDISPLAY=""; return; }

  local match
  # Search history for a command beginning with current buffer
  match=$(fc -ln 1 2>/dev/null | awk -v q="$BUFFER" '
    {
      line=$0
      if (index(line,q)==1 && length(line)>length(q)) {
        print line
        exit
      }
    }
  ')

  if [[ -n $match ]]; then
    _ksh_sugg="${match#$BUFFER}"
    POSTDISPLAY="$_ksh_sugg"
    region_highlight=("${#BUFFER} $((${#BUFFER}+${#POSTDISPLAY})) ${KSH_AUTOSUGGEST_COLOR}")
  else
    POSTDISPLAY=""
    region_highlight=()
  fi
}

_ksh_accept() {
  if [[ -n $POSTDISPLAY ]]; then
    BUFFER="$BUFFER$POSTDISPLAY"
    CURSOR=${#BUFFER}
    POSTDISPLAY=""
  else
    zle forward-char 2>/dev/null || zle end-of-line
  fi
}

_ksh_accept_word() {
  if [[ -n $POSTDISPLAY ]]; then
    local word
    word="${POSTDISPLAY%% *} "
    BUFFER="$BUFFER$word"
    CURSOR=${#BUFFER}
    POSTDISPLAY="${POSTDISPLAY#$word}"
  else
    zle forward-word 2>/dev/null
  fi
}

zle -N _ksh_accept
zle -N _ksh_accept_word

# Hook into line editor — recompute on each key press
autoload -U add-zle-hook-widget 2>/dev/null || true
_ksh_redraw() { _ksh_suggest; }
zle -N _ksh_redraw

# Bind: Right arrow and Ctrl+F accept full; Alt+F accepts word
bindkey '^[[C'  _ksh_accept        # →
bindkey '^F'    _ksh_accept        # Ctrl+F
bindkey '^[f'   _ksh_accept_word   # Alt+f

# Recompute after every self-insert / backspace
_ksh_self_insert() { zle .self-insert; _ksh_suggest; }
_ksh_backspace()   { zle .backward-delete-char; _ksh_suggest; }
zle -N self-insert _ksh_self_insert
zle -N backward-delete-char _ksh_backspace
