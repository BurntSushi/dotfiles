#!/bin/sh

startup &
sleep 2
video main
nitrogen --restore
gkrellm &
idesk &
no-blanking-loop &
dunst &
nm-applet &
restart-compositor &

exec bash -c '(dbus-launch run-wingo ; (while true; do sleep 1000; done))'
