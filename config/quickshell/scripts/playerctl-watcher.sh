#!/bin/bash
pkill -f "playerctl -F metadata" 2>/dev/null
while true; do
  playerctl -F metadata -f "{{status}}|{{title}}|{{artist}}" > /tmp/playerctl-status
  sleep 2
done
