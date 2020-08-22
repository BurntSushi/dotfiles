#!/bin/sh

startup &
sleep 2
video tv
nitrogen --restore
# compton --backend glx --vsync opengl --vsync-aggressive &
gkrellm &
idesk &
no-blanking-loop &
dunst &
media &

#if [ -z "$(ls /m)" ]; then
#  media >> $HOME/data/log/media.log 2>&1 &
#fi

exec bash -c '(dbus-launch run-wingo ; (while true; do sleep 1000; done))'
