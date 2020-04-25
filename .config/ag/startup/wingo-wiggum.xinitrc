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
# (sleep 1 && video tv) &
video tv
nitrogen --restore
gkrellm &
idesk &
no-blanking-loop &
dunst &
nm-applet &
kmix --keepvisibility &

exec bash -c '(dbus-launch run-wingo ; (while true; do sleep 1000; done))'
