#!/bin/sh

startup
screenpos main &
dunst &
ag-blueberry-tray &
restart-compositor &

# Run the 1password tray.
1password \
  --silent \
  --force-device-scale-factor=1.5 \
  --log=debug &> /tmp/1password.log &

exec run-wingo-environment
