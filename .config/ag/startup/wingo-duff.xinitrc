#!/bin/sh

startup &
media
screenpos left middle right
nitrogen --restore
dunst &
exec run-wingo-environment
