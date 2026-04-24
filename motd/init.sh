#!/data/data/com.termux/files/usr/bin/env bash
# KSUI motd — vendored from GR3YH4TT3R93/termux-motd, re-implemented
# in bash (no zsh dependency) and branded as Kashsight.
#
# Runs every motd.d/NN-* script in numeric order, skipping .disabled.

MOTD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/motd.d"
[[ -d $MOTD_DIR ]] || exit 0

# Collect executable / readable scripts sorted by numeric prefix
shopt -s nullglob
for script in "$MOTD_DIR"/[0-9]*; do
  [[ $script == *.disabled ]] && continue
  [[ -r $script ]] || continue
  if [[ -x $script ]]; then
    "$script"
  else
    bash "$script"
  fi
done
