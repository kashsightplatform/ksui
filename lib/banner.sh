#!/data/data/com.termux/files/usr/bin/env bash
# KSUI — banner builder
# Composes block-ASCII text from $KSUI_HOME/assets/alphabet.txt and writes
# it to $KSUI_HOME/assets/banner.txt (the customizable banner file shown by
# `motd` / `ksui motd`). Rejects anything outside [a-zA-Z0-9].

banner::_alphabet_file() { printf '%s' "${KSUI_HOME:-$HOME/.ksui-app}/assets/alphabet.txt"; }
banner::_output_file()   { printf '%s' "${KSUI_HOME:-$HOME/.ksui-app}/assets/banner.txt"; }

# banner::build <text>
# Validates the text, renders it, prints to stdout, and saves it as the
# new banner file. Returns 1 on validation/render error.
banner::build() {
  local text="$*"
  if [[ -z $text ]]; then
    printf 'banner: usage: banner <text>   (a-z, A-Z, 0-9 only — no spaces, emojis, or punctuation)\n' >&2
    return 1
  fi
  if [[ ! $text =~ ^[A-Za-z0-9]+$ ]]; then
    printf 'banner: rejected — only letters and digits are allowed (got: %q)\n' "$text" >&2
    return 1
  fi

  local alpha; alpha=$(banner::_alphabet_file)
  if [[ ! -f $alpha ]]; then
    printf 'banner: alphabet file missing: %s\n' "$alpha" >&2
    return 1
  fi

  # Parse alphabet into associative arrays: glyph[CHAR][row]=line
  declare -A G0 G1 G2 G3 G4
  local cur="" row=0 line
  while IFS= read -r line || [[ -n $line ]]; do
    [[ $line == \#* ]] && continue
    if [[ $line == :* ]]; then
      cur=${line#:}
      cur=${cur^^}
      row=0
      continue
    fi
    [[ -z $cur ]] && continue
    case $row in
      0) G0[$cur]=$line ;;
      1) G1[$cur]=$line ;;
      2) G2[$cur]=$line ;;
      3) G3[$cur]=$line ;;
      4) G4[$cur]=$line ;;
    esac
    row=$((row + 1))
  done < "$alpha"

  # Build 5 output rows by concatenating glyphs with a single-space gap.
  local r0="" r1="" r2="" r3="" r4=""
  local i ch upper
  for (( i=0; i<${#text}; i++ )); do
    ch=${text:$i:1}
    upper=${ch^^}
    if [[ -z ${G0[$upper]+x} ]]; then
      printf 'banner: no glyph for %q in alphabet\n' "$ch" >&2
      return 1
    fi
    [[ -n $r0 ]] && { r0+=" "; r1+=" "; r2+=" "; r3+=" "; r4+=" "; }
    r0+="${G0[$upper]}"
    r1+="${G1[$upper]}"
    r2+="${G2[$upper]}"
    r3+="${G3[$upper]}"
    r4+="${G4[$upper]}"
  done

  local out; out=$(banner::_output_file)
  mkdir -p "$(dirname "$out")"
  {
    printf '%s\n' "$r0"
    printf '%s\n' "$r1"
    printf '%s\n' "$r2"
    printf '%s\n' "$r3"
    printf '%s\n' "$r4"
  } > "$out"

  # Echo a colored copy to the user (cyan→blue gradient like the logo).
  local C=$'\033[38;5;51m' D=$'\033[38;5;39m' R=$'\033[0m'
  printf '\n%s%s%s\n' "$C" "$r0" "$R"
  printf '%s%s%s\n'   "$C" "$r1" "$R"
  printf '%s%s%s\n'   "$D" "$r2" "$R"
  printf '%s%s%s\n'   "$D" "$r3" "$R"
  printf '%s%s%s\n\n' "$D" "$r4" "$R"
  printf '\033[2m  saved → %s\033[0m\n' "$out"
}
