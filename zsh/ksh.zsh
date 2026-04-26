# KSH — Kashsight Shell framework
# A small, self-contained zsh framework. Replaces oh-my-zsh for KSUI users.
# Load it from ~/.zshrc with:
#   source "$HOME/.ksui-app/zsh/ksh.zsh"
#
# What it loads (all opt-out via KSH_SKIP_*):
#   • history sensible defaults
#   • completion + menu select
#   • vendored autosuggestions + syntax-highlighting
#   • vendored `z` (frecent dir jump)
#   • KSUI prompt theme
#   • git / pkg / termux aliases
#   • KSUI motd on new sessions

: ${KSH_HOME:=${0:A:h}}
export KSH_HOME

# ── 1. history ────────────────────────────────────────────────────────────
if (( ! ${KSH_SKIP_HISTORY:-0} )); then
  HISTFILE=${HISTFILE:-$HOME/.zsh_history}
  HISTSIZE=50000
  SAVEHIST=50000
  setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS
  setopt SHARE_HISTORY APPEND_HISTORY INC_APPEND_HISTORY
fi

# ── 2. completion ─────────────────────────────────────────────────────────
if (( ! ${KSH_SKIP_COMPLETION:-0} )); then
  autoload -Uz compinit
  compinit -C 2>/dev/null
  zstyle ':completion:*' menu select
  zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
  zstyle ':completion:*' list-colors ''
fi

# ── 3. key bindings ──────────────────────────────────────────────────────
bindkey -e  # emacs-style by default
bindkey '^[[A' up-line-or-history
bindkey '^[[B' down-line-or-history
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# ── 4. plugins (all vendored under zsh/plugins/) ──────────────────────────
if (( ! ${KSH_SKIP_AUTOSUGGEST:-0} )); then
  [[ -f "$KSH_HOME/plugins/autosuggestions/autosuggestions.zsh" ]] && \
    source "$KSH_HOME/plugins/autosuggestions/autosuggestions.zsh"
fi

if (( ! ${KSH_SKIP_Z:-0} )); then
  [[ -f "$KSH_HOME/plugins/z/z.sh" ]] && source "$KSH_HOME/plugins/z/z.sh"
fi

if (( ! ${KSH_SKIP_FZF:-0} )); then
  [[ -f "$KSH_HOME/plugins/fzf/fzf.zsh" ]] && \
    source "$KSH_HOME/plugins/fzf/fzf.zsh"
fi

# Syntax highlighting MUST load last (it hooks the line editor)
if (( ! ${KSH_SKIP_SYNTAX:-0} )); then
  [[ -f "$KSH_HOME/plugins/syntax-highlighting/syntax-highlighting.zsh" ]] && \
    source "$KSH_HOME/plugins/syntax-highlighting/syntax-highlighting.zsh"
fi

# ── 5. prompt theme ──────────────────────────────────────────────────────
if (( ! ${KSH_SKIP_THEME:-0} )); then
  # Theme selection: ~/.ksui/theme  (written by `ksui theme <name>`)
  local _ksh_theme="ksui"
  [[ -f "$HOME/.ksui/theme" ]] && _ksh_theme=$(<"$HOME/.ksui/theme")
  if [[ -f "$KSH_HOME/themes/${_ksh_theme}.zsh-theme" ]]; then
    source "$KSH_HOME/themes/${_ksh_theme}.zsh-theme"
  elif [[ -f "$KSH_HOME/themes/ksui.zsh-theme" ]]; then
    source "$KSH_HOME/themes/ksui.zsh-theme"
  fi
  unset _ksh_theme
fi

# ── 6. aliases ───────────────────────────────────────────────────────────
if (( ! ${KSH_SKIP_ALIASES:-0} )); then
  # ls with icons (lsd if available)
  if command -v lsd >/dev/null 2>&1; then
    alias ls='lsd --icon=always --icon-theme=unicode --group-dirs=first'
    alias ll='lsd -l --icon=always --icon-theme=unicode --group-dirs=first'
    alias la='lsd -la --icon=always --icon-theme=unicode --group-dirs=first'
    alias lt='lsd --tree --icon=always --icon-theme=unicode'
  else
    alias ls='ls --color=auto'
    alias ll='ls -lh --color=auto'
    alias la='ls -lah --color=auto'
  fi

  # nav
  alias ..='cd ..'
  alias ...='cd ../..'
  alias ....='cd ../../..'
  alias c='clear'

  # git
  alias g='git'
  alias gs='git status'
  alias ga='git add'
  alias gc='git commit'
  alias gca='git commit --amend'
  alias gp='git push'
  alias gpl='git pull'
  alias gl='git log --oneline --graph --decorate'
  alias gd='git diff'
  alias gb='git branch'
  alias gco='git checkout'

  # pkg (termux)
  if command -v pkg >/dev/null 2>&1; then
    alias pu='pkg update && pkg upgrade'
    alias pi='pkg install'
    alias pr='pkg remove'
    alias ps='pkg search'
  fi

  # termux-api
  if command -v termux-info >/dev/null 2>&1; then
    alias tinfo='termux-info'
    alias tbat='termux-battery-status'
    alias twifi='termux-wifi-enable'
    alias tloc='termux-location'
  fi
fi

# ── 6b. session lock (username + password on shell startup) ─────────────
# Opt out: `touch ~/.ksui/no-lock`, or set KSH_SKIP_AUTH=1 before sourcing.
if (( ! ${KSH_SKIP_AUTH:-0} )) && [[ -o interactive && -z $KSUI_REPL ]]; then
  if [[ -x "$KSH_HOME/../lib/session-auth.sh" ]]; then
    "$KSH_HOME/../lib/session-auth.sh" || {
      print -u2 "ksui: session locked"
      exec sleep 86400
    }
  fi
fi

# ── 7. motd on new shell ─────────────────────────────────────────────────
# Run via precmd so it fires AFTER powerlevel10k's instant-prompt preamble
# (printing during init triggers the p10k warning). Show it once, on the
# first prompt redraw, then unhook.
if (( ! ${KSH_SKIP_MOTD:-0} )) && [[ -o interactive ]]; then
  _ksh_motd="$KSH_HOME/../motd/init.sh"
  if [[ -r $_ksh_motd ]]; then
    _ksui_show_motd() {
      [[ -x $_ksh_motd ]] && "$_ksh_motd" || bash "$_ksh_motd"
      add-zsh-hook -d precmd _ksui_show_motd
      unset -f _ksui_show_motd
    }
    autoload -Uz add-zsh-hook
    add-zsh-hook precmd _ksui_show_motd
  fi
fi

# ── 7b. silence Termux's "pkg install X" suggestions ─────────────────────
# Termux's /etc/zshrc installs a command_not_found_handler that nags about
# installing packages on every miss — including spurious misses caused by a
# stale command hash. KSUI is a no-nag UI: drop the handler and refresh the
# hash table on each chdir so PATH lookups stay fresh.
if (( ! ${KSH_SKIP_NONAG:-0} )); then
  command_not_found_handler() {
    print -u2 "ksui: command not found: $1"
    return 127
  }
  autoload -Uz add-zsh-hook
  _ksh_rehash() { rehash 2>/dev/null; }
  add-zsh-hook chpwd _ksh_rehash
  rehash 2>/dev/null
fi

# ── 8. expose KSUI one-shot commands as zsh functions ───────────────────
# So users can type `weather nairobi`, `joke`, `crypto btc`, etc. directly
# from any zsh prompt — no login, no REPL, no password. The interactive
# REPL is still available via plain `ksui`.
# Opt out with KSH_SKIP_KAI_CMDS=1.
if (( ! ${KSH_SKIP_KAI_CMDS:-0} )) && command -v ksui >/dev/null 2>&1; then
  for _kai_cmd in ask joke fact meme news crypto ip define weather sysinfo \
                  qr note notes todo timer doctor motd banner; do
    # Skip if the user already has a command/alias by that name.
    if ! command -v "$_kai_cmd" >/dev/null 2>&1; then
      eval "${_kai_cmd}() { ksui ${_kai_cmd} \"\$@\"; }"
    fi
  done
  unset _kai_cmd
fi
