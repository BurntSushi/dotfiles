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
  xset m 2 1
) &

video one
nitrogen --restore
compton --vsync drm &
gkrellm &
rox -p default

no-blanking-loop &

exec bash -c '(dbus-launch run-wingo ; (while true; do sleep 1000; done))'

