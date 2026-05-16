#!/bin/sh

startup &
nitrogen --restore
(
  sleep 0.3
  video laptop
  dunst &
  nm-applet &
  ag-blueberry-tray &
  (volume mute ; volume mute) &
) &
exec run-wingo-environment
