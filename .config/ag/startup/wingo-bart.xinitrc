#!/usr/bin/env bash

set -e

run-wingo-environment &
while ! pgrep '^wingo$'; do
  sleep 0.1s
done

startup
video main &
variety &
dunst &
ag-blueberry-tray &
(volume mute ; volume mute) &
restart-compositor &
if is-laptop; then
  nm-applet &
  autobright &

  # An agent to make the fingerprint sensor work.
  /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
fi

# Run the 1password tray.
1password \
  --silent \
  --force-device-scale-factor=1.5 \
  --log=debug &> /tmp/1password.log &

while true; do sleep 86400s; done
