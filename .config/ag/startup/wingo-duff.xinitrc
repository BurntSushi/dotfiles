#!/bin/sh

startup &
media
video left middle right
nitrogen --restore
dunst &

exec bash -c '(run-wingo ; (while true; do sleep 1000; done))'
