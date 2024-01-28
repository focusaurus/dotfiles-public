#!/bin/sh
xrandr \
  --output eDP1 --mode 1920x1080 --pos 0x0 --rotate normal --primary \
  --output DP2  --mode 2560x1440 --pos 0x0 --rotate normal \
  --output HDMI1 --off \
  --output HDMI2 --off \
  --output VIRTUAL1 --off \
  --output DP1 --off
