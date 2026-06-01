#!/bin/sh

startup &
sleep 2
screenpos tv
nitrogen --restore
gkrellm &
idesk &
no-blanking-loop &
dunst &
nm-applet &
restart-compositor &
(sleep 2 && screenpos tv) &

exec bash -c '(dbus-launch run-wingo ; (while true; do sleep 1000; done))'
