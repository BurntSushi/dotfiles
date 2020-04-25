#!/bin/sh

( xrdb $HOME/.Xresources
  xsetroot -cursor_name left_ptr
  setxkbmap -option terminate:ctrl_alt_bksp
  xset r rate 200
  xset b 0
  xmodmap $HOME/.xmodmaprc
  xbindkeys
  numlockx on
  dpms-settings
  no-blanking
  xset m 3 1
) &

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
