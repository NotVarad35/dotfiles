#!/bin/bash
# Toggle Ultra Performance Mode
# Usage: toggle-perf-mode.sh [on|off]
#   on    - Enter performance mode
#   off   - Leave performance mode
#   (none) - Auto-detect (checks if config.conf.normal exists)

MODE="${1:-auto}"
CONFIG_DIR="$HOME/.config/mango"
NORMAL="$CONFIG_DIR/config.conf.normal"
PERF="$CONFIG_DIR/config-performance.conf"
ACTIVE="$CONFIG_DIR/config.conf"
WALL="$HOME/Pictures/walls/wallhaven-3q9qky.png"
SETTINGS="$HOME/.config/noctalia/settings.json"

# Auto-detect mode
if [ "$MODE" = "auto" ]; then
  if [ -f "$NORMAL" ]; then
    MODE="off"
  else
    MODE="on"
  fi
fi

# === LEAVE PERFORMANCE MODE ===
if [ "$MODE" = "off" ]; then
  if [ ! -f "$NORMAL" ]; then
    notify-send "Performance mode" "Not in performance mode"
    exit 0
  fi

  # Restore config
  cp "$NORMAL" "$ACTIVE"
  rm "$NORMAL"

  # Restore wallpaper color extraction if it was on before
  if [ -f /tmp/perf-mode-colorscheme ]; then
    PREV=$(cat /tmp/perf-mode-colorscheme)
    if [ "$PREV" = "true" ]; then
      sed -i 's/"useWallpaperColors": false/"useWallpaperColors": true/' "$SETTINGS"
    fi
    rm /tmp/perf-mode-colorscheme
  fi

  # Restart Noctalia
  qs -c noctalia-shell &

  # Kill perf mode services
  pkill swaybg mako nm-applet 2>/dev/null

  # Reload mangowm
  sleep 0.5
  killall -USR1 mango 2>/dev/null

  notify-send "Performance mode" "OFF — restored"

# === ENTER PERFORMANCE MODE ===
elif [ "$MODE" = "on" ]; then
  if [ -f "$NORMAL" ]; then
    notify-send "Performance mode" "Already in performance mode"
    exit 0
  fi

  # Save current config as normal backup
  cp "$ACTIVE" "$NORMAL"

  # Create perf config if needed
  if [ ! -f "$PERF" ]; then
    cat > "$PERF" << 'PERFEOF'
#My MangoWM config - Performance Mode (minimal)

####################################################################################
# Startup + env
####################################################################################

exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=wlroots
exec-once = /usr/lib/xdg-desktop-portal-wlr
exec-once = fcitx5 -d
exec-once = swaybg -i /home/notvarad/Pictures/walls/wallhaven-3q9qky.png
exec-once = mako
exec-once = nm-applet

env = XCURSOR_THEME,Bogpackwin
env = XCURSOR_SIZE,24
env = GTK_IM_MODULE,fcitx
env = QT_IM_MODULE,fcitx
env = QT_IM_MODULES,wayland;fcitx
env = SDL_IM_MODULE,fcitx
env = XMODIFIERS,@im=fcitx
env = QT_QPA_PLATFORMTHEME,qt6ct

###################################################################################
#General Appearance
###################################################################################

border_radius=20
no_radius_when_single=0
no_border_when_single=0
borderpx=1
focused_opacity=1
unfocused_opacity=1

gappih=10
gappiv=15
gappoh=15
gappov=15
scratchpad_width_ratio=0.8
scratchpad_height_ratio=0.9

#Blur
blur=0

#Shadows
shadows=0

#animations
animations=0

###################################################################################
# Layouts
###################################################################################

tagrule=id:1,layout_name:tile
tagrule=id:2,layout_name:tile
tagrule=id:3,layout_name:tile
tagrule=id:4,layout_name:tile
tagrule=id:5,layout_name:tile
tagrule=id:6,layout_name:tile
tagrule=id:7,layout_name:tile
tagrule=id:8,layout_name:tile
tagrule=id:9,layout_name:tile

scroller_structs=20
scroller_default_proportion=0.5
scroller_focus_center=0
scroller_prefer_center=0
edge_scroller_pointer_focus=1
scroller_default_proportion_single=1.0
scroller_proportion_preset=0.5,0.8,1.0

new_is_master=0
default_mfact=0.5
default_nmaster=0
smartgaps=0

hotarea_size=10
enable_hotarea=1
ov_tab_mode=0
overviewgappi=5
overviewgappo=30

###################################################################################
# peripherals
###################################################################################

repeat_rate=50
repeat_delay=225
numlockon=0
xkb_rules_layout=us,jp
xkb_rules_options=grp:lalt_lshift_toggle

disable_trackpad=0
tap_to_click=1
tap_and_drag=1
drag_lock=1
trackpad_natural_scrolling=1
disable_while_typing=1
left_handed=0
middle_button_emulation=0
swipe_min_threshold=1

mouse_natural_scrolling=0

####################################################################################
# Misc
###################################################################################

focus_on_activate=1
idleinhibit_ignore_visible=0
sloppyfocus=1
warpcursor=1
focus_cross_monitor=0
focus_cross_tag=0
enable_floating_snap=0
snap_distance=30
cursor_size=24
drag_tile_to_tile=1
axis_bind_apply_timeout=100

####################################################################################
# keybinds
###################################################################################

bind=SUPER+SHIFT,r,reload_config

# Applications
bind=SUPER,Q,spawn,foot
bind=SUPER,e,spawn,thunar
bind=SUPER+SHIFT,e,spawn,pkill mango
bind=SUPER,space,spawn,walker -t noctalia
bind=SUPER,b,spawn,firefox

# Window Focus
bind=SUPER,h,focusdir,left
bind=SUPER,l,focusdir,right
bind=SUPER,k,focusdir,up
bind=SUPER,j,focusdir,down

# Window Swap
bind=SUPER+SHIFT,k,exchange_client,up
bind=SUPER+SHIFT,j,exchange_client,down
bind=SUPER+SHIFT,h,exchange_client,left
bind=SUPER+SHIFT,l,exchange_client,right

# Window State
bind=SUPER,w,killclient,
bind=SUPER,g,toggleglobal,
bind=SUPER,v,togglefloating,
bind=ALT,a,togglemaximizescreen,
bind=super,f,togglefullscreen,
bind=SUPER,i,minimized,
bind=SUPER+SHIFT,I,restore_minimized

# Window Move
bind=ALT+SHIFT,Up,movewin,+0,-50
bind=ALT+SHIFT,Down,movewin,+0,+50
bind=ALT+SHIFT,Left,movewin,-50,+0
bind=ALT+SHIFT,Right,movewin,+50,+0

# Window Resize
bind=SUPER+ALT,Up,resizewin,+0,-50
bind=SUPER+ALT,Down,resizewin,+0,+50
bind=SUPER+ALT,Left,resizewin,-50,+0
bind=SUPER+ALT,Right,resizewin,+50,+0

# Workspace
bind=CTRL+SUPER,Left,viewtoleft,0
bind=CTRL+SUPER,Right,viewtoright,0

# Layout
bind=SUPER,n,switch_layout

# Tags (view)
bind=SUPER,1,view,1,0
bind=SUPER,2,view,2,0
bind=SUPER,3,view,3,0
bind=SUPER,4,view,4,0
bind=SUPER,5,view,5,0
bind=SUPER,6,view,6,0
bind=SUPER,7,view,7,0
bind=SUPER,8,view,8,0
bind=SUPER,9,view,9,0

# Tags (move client)
bind=SUPER+SHIFT,1,tag,1,0
bind=SUPER+SHIFT,2,tag,2,0
bind=SUPER+SHIFT,3,tag,3,0
bind=SUPER+SHIFT,4,tag,4,0
bind=SUPER+SHIFT,5,tag,5,0
bind=SUPER+SHIFT,6,tag,6,0
bind=SUPER+SHIFT,7,tag,7,0
bind=SUPER+SHIFT,8,tag,8,0
bind=SUPER+SHIFT,9,tag,9,0

# Screenshot
bind=NONE,Print,spawn,~/.config/mango/scripts/screenshot.sh
bind=SUPER+SHIFT,S,spawn,~/.config/mango/scripts/screenshot-annotate.sh
bind=SUPER+SHIFT,V,spawn,~/.config/mango/scripts/clipboard.sh

# volume and audio
bind=NONE,XF86AudioRaiseVolume,spawn,pactl set-sink-volume @DEFAULT_SINK@ +5%
bind=NONE,XF86AudioLowerVolume,spawn,pactl set-sink-volume @DEFAULT_SINK@ -5%
bind=NONE,XF86AudioMute,spawn,pactl set-sink-mute @DEFAULT_SINK@ toggle
bind=NONE,XF86AudioMicMute,spawn,pactl set-source-mute @DEFAULT_SOURCE@ toggle
bind=NONE,F3,spawn,pactl set-sink-volume @DEFAULT_SINK@ +5%
bind=NONE,F2,spawn,pactl set-sink-volume @DEFAULT_SINK@ -5%
bind=NONE,F1,spawn,pactl set-sink-mute @DEFAULT_SINK@ toggle
bind=NONE,F4,spawn,pactl set-source-mute @DEFAULT_SOURCE@ toggle

# brightness
bind=NONE,XF86MonBrightnessUp,spawn,brightnessctl set +10%
bind=NONE,XF86MonBrightnessDown,spawn,brightnessctl set 10%-

# Lock screen
bind=SUPER+ALT,l,spawn,~/.local/bin/lock.sh

# mouse bindings
mousebind=SUPER,btn_left,moveresize,curmove
mousebind=SUPER,btn_right,moveresize,curresize
PERFEOF
  fi

  # Save wallpaper color extraction state
  if grep -q '"useWallpaperColors": true' "$SETTINGS" 2>/dev/null; then
    echo "true" > /tmp/perf-mode-colorscheme
    sed -i 's/"useWallpaperColors": true/"useWallpaperColors": false/' "$SETTINGS"
  else
    echo "false" > /tmp/perf-mode-colorscheme
  fi

  # Apply perf config
  cp "$PERF" "$ACTIVE"

  # Kill Noctalia
  killall -9 qs 2>/dev/null

  # Reload mangowm
  sleep 0.3
  killall -USR1 mango 2>/dev/null

  notify-send "Performance mode" "ON — resources freed"
fi
