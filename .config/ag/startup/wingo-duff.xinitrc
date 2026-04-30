#!/bin/sh

startup &
media
video left middle right
nitrogen --restore
dunst &

# 1. Explicitly point all X11 apps to the native systemd user bus.
dbus-update-activation-environment --systemd DISPLAY XAUTHORITY XDG_CURRENT_DESKTOP
# 2. Execute Wingo (now natively inheriting the systemd bus).
exec bash -c '(run-wingo ; (while true; do sleep 1000; done))'
