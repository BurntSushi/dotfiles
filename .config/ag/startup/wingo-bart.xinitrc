#!/bin/sh

set -x
set -e

startup
screenpos laptop &
variety &
dunst &
nm-applet &
ag-blueberry-tray &
(volume mute ; volume mute) &
restart-compositor &
autobright &

# An agent to make the fingerprint sensor work.
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
# Run the 1password tray.
1password \
  --silent \
  --force-device-scale-factor=1.5 \
  --log=debug &> /tmp/1password.log &

exec run-wingo-environment
