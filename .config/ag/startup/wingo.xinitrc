#!/bin/sh

# vim: ft=sh sw=2 ts=2 sts=2

base="$HOME/.config/ag/startup"
case "$(myhostname)" in
  bart)
    exec "$base/wingo-bart.xinitrc" &> /tmp/run-wingo-environment.log
    ;;
  kang)
    exec "$base/wingo-kang.xinitrc"
    ;;
  nas2)
    exec "$base/wingo-nas2.xinitrc"
    ;;
  duff)
    exec "$base/wingo-duff.xinitrc"
    ;;
  flanders)
    exec "$base/wingo-flanders.xinitrc"
    ;;
  milhouse)
    exec "$base/wingo-milhouse.xinitrc"
    ;;
  wiggum)
    exec "$base/wingo-wiggum.xinitrc"
    ;;
  otto)
    exec "$base/wingo-otto.xinitrc"
    ;;
esac
