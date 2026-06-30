#!/usr/bin/env bash
THEMES_DIR=/usr/share/sddm/themes
THEMES=(enfield field forest girl-pillow last-of-us man-bicycle material-you minecraft pixel-coffee pixel-cyberpunk pixel-dusk-city pixel-hollowknight pixel-munchlax pixel-night-city pixel-rainyroom pixel-sakura pixel-skyscrapers pixel-waterfall sword winter women-umbrella wuwa)
LOCK_DIR="$HOME/.local/share/quickshell-lockscreen"

RANDOM_THEME=${THEMES[$RANDOM % ${#THEMES[@]}]}

# Update SDDM config for next boot
sudo sed -i "s/^Current=.*/Current=$RANDOM_THEME/" /etc/sddm.conf.d/theme.conf

# Set theme for quickshell lock
echo "$RANDOM_THEME" > "$HOME/.config/qylock/theme"

"$LOCK_DIR/lock.sh" "$RANDOM_THEME"
