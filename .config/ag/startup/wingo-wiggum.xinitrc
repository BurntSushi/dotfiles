#!/bin/sh

startup &
sleep 2
# (sleep 1 && video tv) &
video tv
nitrogen --restore
gkrellm &
idesk &
no-blanking-loop &
dunst &
nm-applet &
kmix --keepvisibility &

exec bash -c '(dbus-launch run-wingo ; (while true; do sleep 1000; done))'
