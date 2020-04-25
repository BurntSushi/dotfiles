#!/bin/sh

dunst &
( xrdb $HOME/.Xresources
  xsetroot -cursor_name left_ptr
  setxkbmap -option terminate:ctrl_alt_bksp
  xset r rate 200
  xset b 0
  xmodmap $HOME/.xmodmaprc
  xbindkeys -f $HOME/.xbindkeysrc
  numlockx on
  dpms-settings
  xset m 2 1
  autobright
) &

nitrogen --restore
compton --backend glx --vsync opengl-swc &
(
  sleep 0.1
  video laptop
  kmix --keepvisibility &
  nm-applet &
  # wicd-client --tray &
  gkrellm &
) &

exec bash -c '(dbus-launch run-wingo ; (while true; do sleep 1000; done))'
