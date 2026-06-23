#!/usr/bin/env bash
set -euo pipefail

RICE_DIR="$(cd "$(dirname "$0")" && pwd)"

link_config() {
  local src="$RICE_DIR/config/$1"
  local dst="$HOME/.config/$1"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "WARNING: $dst exists and is not a symlink — skipping"
    return
  fi
  ln -sfn "$src" "$dst"
  echo "linked $src → $dst"
}

link_config mango
link_config foot
link_config wofi

mkdir -p "$HOME/.local/bin"
for script in "$RICE_DIR"/scripts/*; do
  [ -f "$script" ] || continue
  chmod +x "$script"
  ln -sf "$script" "$HOME/.local/bin/$(basename "$script")"
  echo "linked $script → ~/.local/bin/$(basename "$script")"
done

echo "done — relog or reload mango to apply"
