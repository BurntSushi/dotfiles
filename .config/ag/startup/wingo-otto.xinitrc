#!/usr/bin/env zsh

# startup &
# sleep 2
# video tv
# nitrogen --restore
# gkrellm &
# idesk &
# no-blanking-loop &
# dunst &
# nm-applet &
# restart-compositor &
#
# exec bash -c '(dbus-launch run-wingo ; (while true; do sleep 1000; done))'

startup &
nitrogen --restore &
video laptop &
dunst &
nm-applet &
ag-blueberry-tray &
restart-compositor &

# Run the 1password tray.
1password \
  --silent \
  --force-device-scale-factor=1.5 \
  --log=debug &> /tmp/1password.log &

exec run-wingo-environment
