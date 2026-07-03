#!/bin/bash
# Wallpaper Maker - save images to ~/Pictures/walls/
WALLS_DIR="$HOME/Pictures/walls"
mkdir -p "$WALLS_DIR"

MODE=$(printf "Screenshot\nURL\nReddit\nClipboard" | walker -d -p "Wallpaper source?")

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
  FILENAME=$(basename "$URL" | cut -d? -f1 | sed 's/[^a-zA-Z0-9._-]//g')
  [ -z "$FILENAME" ] && FILENAME="wallpaper-$(date +%s).png"
  curl -sLo "$WALLS_DIR/$FILENAME" "$URL"
  if [ $? -eq 0 ] && [ -f "$WALLS_DIR/$FILENAME" ]; then
    notify-send "Wallpaper Maker" "Saved: $FILENAME"
  else
    notify-send "Wallpaper Maker" "Download failed"
  fi

# --- Reddit ---
elif [ "$MODE" = "Reddit" ]; then
  JSON=$(curl -s -H "User-Agent: Mozilla/5.0" "https://www.reddit.com/r/wallpaper/hot.json?limit=20")
  ENTRIES=$(echo "$JSON" | jq -r '.data.children[] | 
    .data.url as $url |
    (.data.title | gsub("[^a-zA-Z0-9 ]"; "") | gsub("  *"; " ")) as $title |
    select($url | test("\\.(jpg|jpeg|png|gif|webp)($|\\?)")) |
    "\($title) | \($url)"' 2>/dev/null)

  if [ -z "$ENTRIES" ]; then
    notify-send "Wallpaper Maker" "No image posts found on Reddit"
    exit 1
  fi

  SELECTED=$(echo "$ENTRIES" | walker -d -p "Pick a wallpaper:")
  [ -z "$SELECTED" ] && exit 1

  IMG_URL=$(echo "$SELECTED" | sed 's/.* | //')
  FILENAME=$(basename "$IMG_URL" | cut -d? -f1 | sed 's/[^a-zA-Z0-9._-]//g')
  [ -z "$FILENAME" ] && FILENAME="reddit-$(date +%s).jpg"

  curl -sLo "$WALLS_DIR/$FILENAME" "$IMG_URL"
  if [ $? -eq 0 ] && [ -f "$WALLS_DIR/$FILENAME" ]; then
    notify-send "Wallpaper Maker" "Saved: $FILENAME"
  else
    notify-send "Wallpaper Maker" "Download failed"
  fi

# --- Clipboard ---
elif [ "$MODE" = "Clipboard" ]; then
  TYPES=$(wl-paste --list-types 2>/dev/null)
  if echo "$TYPES" | grep -q "image"; then
    wl-paste --type image/png > "$WALLS_DIR/clipboard-$(date +%s).png" 2>/dev/null
    if [ $? -eq 0 ] && [ -s "$WALLS_DIR/clipboard-$(date +%s).png" ]; then
      notify-send "Wallpaper Maker" "Saved: clipboard-$(date +%s).png"
    else
      wl-paste --type image/bmp > "$WALLS_DIR/clipboard-$(date +%s).bmp" 2>/dev/null
      if [ $? -eq 0 ] && [ -s "$WALLS_DIR/clipboard-$(date +%s).bmp" ]; then
        notify-send "Wallpaper Maker" "Saved: clipboard-$(date +%s).bmp"
      else
        notify-send "Wallpaper Maker" "Failed to save clipboard image"
      fi
    fi
  else
    notify-send "Wallpaper Maker" "No image in clipboard"
  fi
fi
