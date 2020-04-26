#!/bin/sh

(
  xrdb $HOME/.Xresources
  xsetroot -cursor_name left_ptr
  setxkbmap -option terminate:ctrl_alt_bksp
  xset r rate 200
  xset b 0
  xmodmap $HOME/.xmodmaprc
  xbindkeys
  numlockx on
  dpms-settings
  autobright
  system76-darter-set-kbd-backlight
  system76-darter-configure-touchpad
) &

nitrogen --restore
(
  sleep 0.3
  video laptop
  dunst &
  nm-applet &
  gkrellm &
) &
exec bash -c '(dbus-launch run-wingo ; (while true; do sleep 1000; done))'
