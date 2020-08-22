#!/bin/sh

startup &
media
video left middle right
nitrogen --restore
# (sleep 2 && compton --backend glx --vsync opengl-swc) &
gkrellm &
dunst &

exec bash -c '(dbus-launch run-wingo ; (while true; do sleep 1000; done))'
