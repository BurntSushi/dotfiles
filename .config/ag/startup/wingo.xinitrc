#!/usr/bin/env bash

# vim: ft=sh sw=2 ts=2 sts=2

set -e

base="$HOME/.config/ag/startup"
case "$(myhostname)" in
  bart|nas2|duff|otto)
    run-wingo-environment &
    # Wait for Wingo to start before doing other things that generally require
    # a WM to be present below. e.g., Starting the bottom dock in `video`.
    while ! pgrep '^wingo$'; do
      sleep 0.1s
    done

    startup
    # Most things jsut want to boot to one main monitor, but duff is my special
    # triple monitor setup.
    case "$(myhostname)" in
      duff)
        video left middle right &
        ;;
      *)
        video main
        ;;
    esac
    variety &
    dunst &
    ag-blueberry-tray &
    (volume mute ; volume mute) &
    restart-compositor &
    if cmd-exists nm-applet; then
      nm-applet &
    fi
    if is-laptop; then
      autobright &

      # An agent to make the fingerprint sensor work.
      /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
    fi
    if is-media; then
      idesk &
    fi

    # Run the 1password tray.
    1password \
      --silent \
      --force-device-scale-factor=1.5 \
      --log=debug &> /tmp/1password.log &

    while true; do sleep 86400s; done
    ;;
  kang)
    exec "$base/wingo-kang.xinitrc"
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
esac
