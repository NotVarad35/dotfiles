#!/bin/bash
cliphist list | wofi --dmenu -p "Clipboard" | cliphist decode | wl-copy
