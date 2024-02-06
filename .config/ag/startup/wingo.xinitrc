#!/bin/sh

# vim: ft=sh sw=2 ts=2 sts=2

base="$HOME/.config/ag/startup"
case "$(myhostname)" in
  Turtle)
    exec "$base/wingo-turtle.xinitrc"
    ;;
  monty)
    exec "$base/wingo-monty.xinitrc"
    ;;
  krusty)
    exec "$base/wingo-krusty.xinitrc"
    ;;
  bart)
    exec "$base/wingo-bart.xinitrc"
    ;;
  kang)
    exec "$base/wingo-kang.xinitrc"
    ;;
  kodos)
    exec "$base/wingo-kodos.xinitrc"
    ;;
  duff)
    exec "$base/wingo-duff.xinitrc"
    ;;
  frink)
    exec "$base/wingo-frink.xinitrc"
    ;;
  skinner)
    exec "$base/wingo-skinner.xinitrc"
    ;;
  chalmers)
    exec "$base/wingo-chalmers.xinitrc"
    ;;
  wiggum)
    exec "$base/wingo-wiggum.xinitrc"
    ;;
  otto)
    exec "$base/wingo-otto.xinitrc"
    ;;
esac
