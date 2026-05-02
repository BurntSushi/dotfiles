#!/bin/sh

startup &
media
video left middle right
nitrogen --restore
dunst &
dbus-update-activation-environment \
  --systemd DISPLAY XAUTHORITY XDG_CURRENT_DESKTOP
exec bash -c '(dbus-launch run-wingo ; (while true; do sleep 1000; done))'
