#!/bin/bash
current=$(pactl get-default-sink)
sinks=$(pactl list sinks short | awk '{print $2}')
first=""
next=""
found=false
while IFS= read -r s; do
  [ -z "$first" ] && first="$s"
  if $found; then next="$s"; break; fi
  [ "$s" = "$current" ] && found=true
done <<< "$sinks"
[ -z "$next" ] && next="$first"
pactl set-default-sink "$next"
