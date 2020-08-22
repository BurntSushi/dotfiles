#!/bin/sh

startup &
nitrogen --restore
compton --backend glx --vsync opengl-swc &
dunst &
(
  sleep 0.1
  video laptop
  kmix --keepvisibility &
  nm-applet &
  # wicd-client --tray &
  gkrellm &
) &

exec bash -c '(dbus-launch run-wingo ; (while true; do sleep 1000; done))'
