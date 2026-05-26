#!/bin/sh

startup &
media
video left middle right
nitrogen --restore
dunst &
exec run-wingo-environment
