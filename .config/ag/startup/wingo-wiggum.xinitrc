#!/bin/sh

startup &
nitrogen --restore
gkrellm &
idesk &
no-blanking-loop &
dunst &
nm-applet &
restart-xcompmgr &
(sleep 2 && video tv) &
(sleep 4 && nitrogen --restore) &
(sleep 6 && video tv) &

exec bash -c '(dbus-launch run-wingo ; (while true; do sleep 1000; done))'
