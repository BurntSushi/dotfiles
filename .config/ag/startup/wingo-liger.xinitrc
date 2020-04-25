#!/bin/sh

( xrdb $HOME/.Xresources
  xsetroot -cursor_name left_ptr
  setxkbmap -option terminate:ctrl_alt_bksp
  xset r rate 200
  xset b 0
  xmodmap $HOME/.xmodmaprc
  xbindkeys -f $HOME/.xbindkeysrc
  numlockx on
  dpms-settings
  xset m 1 1
) &

video left middle right
nitrogen --restore
(sleep 1 && video left middle right) &
compton --backend glx --vsync opengl-swc &
gkrellm &
kmix --keepvisibility &

exec bash -c '(dbus-launch run-wingo ; (while true; do sleep 1000; done))'

