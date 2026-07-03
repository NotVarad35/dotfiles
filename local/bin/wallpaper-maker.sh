#!/bin/bash
WALLS_DIR="$HOME/Pictures/walls"
mkdir -p "$WALLS_DIR"

MODE=$(printf "Screenshot\nURL\nClipboard" | walker -d -p "Wallpaper source?")

# --- Screenshot ---
if [ "$MODE" = "Screenshot" ]; then
  NAME=$(walker -d -I -p "Name for screenshot:")
  [ -z "$NAME" ] && exit 1
  grim -g "$(slurp)" "$WALLS_DIR/$NAME.png" 2>/dev/null
  if [ $? -eq 0 ] && [ -f "$WALLS_DIR/$NAME.png" ]; then
    notify-send "Wallpaper Maker" "Saved: $NAME.png"
  else
    notify-send "Wallpaper Maker" "Screenshot cancelled or failed"
  fi

# --- URL ---
elif [ "$MODE" = "URL" ]; then
  URL=$(walker -d -I -p "Image URL:")
  [ -z "$URL" ] && exit 1
  RAW_URL="${URL%%\?*}"
  FILENAME=$(basename "$RAW_URL" | sed 's/[^a-zA-Z0-9._-]//g')
  [ -z "$FILENAME" ] && FILENAME="wallpaper-$(date +%s).png"
  curl -sLo "$WALLS_DIR/$FILENAME" "$RAW_URL"
  if [ $? -eq 0 ] && [ -f "$WALLS_DIR/$FILENAME" ] && [ -s "$WALLS_DIR/$FILENAME" ]; then
    MIME=$(file --mime-type -b "$WALLS_DIR/$FILENAME")
    case "$MIME" in
      image/*) notify-send "Wallpaper Maker" "Saved: $FILENAME ($MIME)" ;;
      *) rm "$WALLS_DIR/$FILENAME"
         notify-send "Wallpaper Maker" "Not a direct image URL (got $MIME, need image/)" ;;
    esac
  else
    notify-send "Wallpaper Maker" "Download failed"
  fi

# --- Clipboard ---
elif [ "$MODE" = "Clipboard" ]; then
  TYPES=$(wl-paste --list-types 2>/dev/null)
  if echo "$TYPES" | grep -q "image"; then
    TS=$(date +%s)
    for MIME in image/png image/jpeg image/webp image/bmp; do
      if wl-paste --type "$MIME" > "$WALLS_DIR/clipboard-$TS.${MIME#image/}" 2>/dev/null && [ -s "$WALLS_DIR/clipboard-$TS.${MIME#image/}" ]; then
        notify-send "Wallpaper Maker" "Saved: clipboard-$TS.${MIME#image/}"
        exit 0
      fi
    done
    notify-send "Wallpaper Maker" "Failed to save clipboard image"
  else
    notify-send "Wallpaper Maker" "No image in clipboard"
  fi
fi
