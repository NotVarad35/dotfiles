#!/usr/bin/env sh
THEMES="enfield field forest girl-pillow last-of-us man-bicycle material-you minecraft pixel-coffee pixel-cyberpunk pixel-dusk-city pixel-hollowknight pixel-munchlax pixel-night-city pixel-rainyroom pixel-sakura pixel-skyscrapers pixel-waterfall sword winter women-umbrella wuwa"
RANDOM_THEME=$(echo "$THEMES" | tr ' ' '\n' | shuf -n1)
sed -i "s/^Current=.*/Current=$RANDOM_THEME/" /etc/sddm.conf.d/theme.conf
echo "$RANDOM_THEME" > /etc/qylock-theme
