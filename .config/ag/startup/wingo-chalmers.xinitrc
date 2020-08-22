#!/bin/sh

startup &
sleep 2
video tv
nitrogen --restore
compton --backend glx --vsync opengl-swc &
gkrellm &
idesk &
no-blanking-loop &

exec bash -c '(dbus-launch run-wingo ; (while true; do sleep 1000; done))'
