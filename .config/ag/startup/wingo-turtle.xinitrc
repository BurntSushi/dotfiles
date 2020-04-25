#!/bin/sh

dunst &
( xrdb $HOME/.Xresources
  xsetroot -cursor_name left_ptr
  setxkbmap -option terminate:ctrl_alt_bksp
  xset r rate 200
  xset b 0
  xmodmap $HOME/.xmodmaprc
  xbindkeys -f $HOME/.xbindkeysrc-turtle
  numlockx on
  dpms-settings
  xset m 2 1
  autobright
) &

xinput set-prop 'SynPS/2 Synaptics TouchPad' 'libinput Tapping Enabled' 1
nitrogen --restore
compton --backend glx --vsync opengl-swc &
(
  sleep 0.1
  video laptop
  kmix --keepvisibility &
  nm-applet &
) &

# This runs the global keyboard shortcut listened for KDE.
# In other words, this gives us nice volume controls.
# kglobalaccel5 &

# exec dbus-launch run-wingo
# exec bash -c '(/home/kait/.gox11/bin/wingo && cat)'
exec bash -c 'run-wingo && cat'
