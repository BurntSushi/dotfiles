#!/usr/bin/env bash

# vim: ft=sh sw=2 ts=2 sts=2

# set -e

base="$HOME/.config/ag/startup"
case "$(myhostname)" in
  bart|flanders|nas2|duff|otto|milhouse)
    x11-init &> /tmp/x11-init.log
    ;;
  kang)
    exec "$base/wingo-kang.xinitrc"
    ;;
  wiggum)
    exec "$base/wingo-wiggum.xinitrc"
    ;;
esac
