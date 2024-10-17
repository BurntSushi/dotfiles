#!/bin/sh

startup &
nitrogen --restore
idesk &
no-blanking-loop &
dunst &
nm-applet &
restart-xcompmgr &
(sleep 1 && video tv) &

exec bash -c '(dbus-launch run-wingo ; (while true; do sleep 1000; done))'
