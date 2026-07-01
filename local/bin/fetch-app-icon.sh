#!/usr/bin/env bash
set -euo pipefail

APP_ID="${1:-}"
APP_NAME="${2:-$APP_ID}"
ICON_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor"

[ -z "$APP_ID" ] && echo "Usage: $0 <app-id> [app-name]" && exit 1

mkdir -p "$ICON_DIR/scalable/apps"

ICON_FILE="$ICON_DIR/scalable/apps/$APP_ID.svg"
if [ -f "$ICON_FILE" ]; then
  echo "Icon already exists for $APP_ID"
  exit 0
fi

# Normalize search term
search() {
  local q="$1"
  [ -z "$q" ] && return
  q=$(echo "$q" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g')
  [ -z "$q" ] && return
  curl -s "https://api.iconify.design/search?query=$q&limit=10" 2>/dev/null
}

pick_best_icon() {
  local json="$1"
  echo "$json" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    icons = data.get('icons', [])
    if not icons:
        sys.exit(1)
    for pref in ['simple-icons', 'logos', 'mdi']:
        for icon in icons:
            if icon.startswith(pref + ':'):
                print(icon.replace(':', '/'))
                sys.exit(0)
    print(icons[0].replace(':', '/'))
except: sys.exit(1)
" 2>/dev/null || true
}

echo "Searching icon for: $APP_NAME ($APP_ID)..."

# Try app name first, then ID
RESULT=""
for term in "$APP_NAME" "$APP_ID" "${APP_NAME%% *}" "${APP_NAME##* }" "${APP_ID##*.}"; do
  [ -z "$term" ] && continue
  json=$(search "$term")
  [ -z "$json" ] && continue
  RESULT=$(pick_best_icon "$json")
  [ -n "$RESULT" ] && break
done

if [ -z "$RESULT" ]; then
  echo "No icon found for: $APP_NAME"
  exit 1
fi

echo "Downloading: $RESULT"
curl -sL "https://api.iconify.design/$RESULT.svg" -o "$ICON_FILE" 2>/dev/null

if [ -f "$ICON_FILE" ] && [ -s "$ICON_FILE" ]; then
  echo "Icon saved: $ICON_FILE"
  gtk-update-icon-cache -f -q "$ICON_DIR" 2>/dev/null || true
else
  echo "Failed to download icon"
  rm -f "$ICON_FILE"
  exit 1
fi
