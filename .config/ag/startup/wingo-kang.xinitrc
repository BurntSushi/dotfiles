#!/bin/sh

startup &
nitrogen --restore
(
  sleep 0.3
  video laptop
  dunst &
  nm-applet &
  blueberry-tray &
) &
exec bash -c '(dbus-launch run-wingo ; (while true; do sleep 1000; done))'
