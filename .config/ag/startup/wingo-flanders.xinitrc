#!/bin/sh

startup &
video tv
sleep 2
nitrogen --restore
idesk &
no-blanking-loop &
dunst &
nm-applet &
restart-xcompmgr &

exec bash -c '(dbus-launch run-wingo ; (while true; do sleep 1000; done))'
