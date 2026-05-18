#!/bin/sh

startup &
nitrogen --restore
(
  sleep 0.3
  video laptop
  dunst &
  (
    1password \
      --silent \
      --force-device-scale-factor=1.5 \
      --log=debug &> /tmp/1password.log
  ) &
  nm-applet &
  ag-blueberry-tray &
  (volume mute ; volume mute) &
  restart-compositor &
) &
exec run-wingo-environment
