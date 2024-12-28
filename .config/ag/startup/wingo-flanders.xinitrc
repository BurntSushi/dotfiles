#!/bin/sh

startup &
sleep 2
video tv
nitrogen --restore
idesk &
no-blanking-loop &
dunst &
nm-applet &
restart-xcompmgr &
(sleep 2 && video tv) &

exec bash -c '(dbus-launch run-wingo ; (while true; do sleep 1000; done))'
