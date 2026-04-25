# KSH z — frecent directory jump (our own implementation)
# Tracks directory visits with (frequency × recency) score, jumps to
# the best match for a partial name.
#
# Usage: z <partial-name>     jump to best match
#        z -l <partial>       list candidates with scores
#        z -c                 restrict to children of PWD
#        z -                  previous dir (like `cd -`)

: ${_Z_DATA:=$HOME/.ksh_z}

_z_track() {
  # Silently no-op when awk or mv aren't installed (common on stock Termux).
  command -v awk >/dev/null 2>&1 || return 0
  command -v mv  >/dev/null 2>&1 || return 0

  local pwd_now=$PWD
  [[ $pwd_now == $HOME ]] && return       # don't track HOME
  [[ -n ${_Z_EXCLUDE_DIRS+x} ]] && {
    for d in "${_Z_EXCLUDE_DIRS[@]}"; do
      [[ $pwd_now == $d/* || $pwd_now == $d ]] && return
    done
  }

  local tmp="${_Z_DATA}.$$"
  local now=$(date +%s) found=0
  : > "$tmp"
  if [[ -f $_Z_DATA ]]; then
    while IFS='|' read -r path rank time; do
      [[ -z $path ]] && continue
      if [[ $path == "$pwd_now" ]]; then
        rank=$(awk "BEGIN{print ${rank:-0} + 1}")
        time=$now
        found=1
      fi
      printf '%s|%s|%s\n' "$path" "$rank" "$time" >> "$tmp"
    done < "$_Z_DATA"
  fi
  (( found )) || printf '%s|%s|%s\n' "$pwd_now" "1" "$now" >> "$tmp"
  mv -f "$tmp" "$_Z_DATA"
}

# Hook into chpwd
chpwd_functions=(${chpwd_functions[@]} _z_track)

unalias z 2>/dev/null
unfunction z 2>/dev/null
z() {
  if ! command -v awk >/dev/null 2>&1; then
    echo "z: awk is required (pkg install gawk)"; return 1
  fi
  local list=0 children=0 pattern
  while (( $# )); do
    case $1 in
      -l) list=1; shift ;;
      -c) children=1; shift ;;
      -)  cd - >/dev/null; return ;;
      *)  pattern="$1"; shift ;;
    esac
  done

  [[ ! -f $_Z_DATA ]] && { echo "z: no data yet — cd around a bit first"; return 1; }

  local now=$(date +%s)
  local best_path="" best_score=0

  # frecent = rank * 1/(age+1)  (simple version of Z's algorithm)
  awk -F'|' -v pat="$pattern" -v pwd="$PWD" -v children="$children" -v now="$now" -v list="$list" '
    {
      path=$1; rank=$2+0; time=$3+0
      if (!path) next
      if (children && index(path, pwd"/") != 1) next
      if (pat && index(path, pat) == 0) next
      age = now - time
      score = rank * (1 / (1 + age/3600))
      if (list) {
        printf "%8.2f  %s\n", score, path
      } else if (score > best) {
        best = score; best_path = path
      }
    }
    END { if (!list && best_path) print best_path }
  ' "$_Z_DATA" | if (( list )); then sort -rn; else read -r target; [[ -n $target ]] && cd "$target" || { echo "z: no match"; return 1; }; fi
}
