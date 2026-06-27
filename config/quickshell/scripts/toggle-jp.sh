#!/bin/bash
# Check current fcitx5 input method
current=$(fcitx5-remote -n 2>/dev/null)
if [ "$current" = "mozc" ]; then
  # Switch to US keyboard and deactivate fcitx
  fcitx5-remote -s keyboard-us
  fcitx5-remote -c
else
  # Activate fcitx and switch to Mozc
  fcitx5-remote -o
  fcitx5-remote -s mozc
fi
