#!/bin/sh

startup &
nitrogen --restore
(
  sleep 0.3
  video laptop
  dunst &
  nm-applet &
  ag-blueberry-tray &
  (volume mute ; volume mute) &
) &
dbus-update-activation-environment \
  --systemd DISPLAY XAUTHORITY XDG_CURRENT_DESKTOP
exec bash -c '(dbus-launch run-wingo ; (while true; do sleep 1000; done))'
