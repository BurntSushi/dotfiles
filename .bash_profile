# vim: ft=sh sw=2 ts=2 sts=2

. "$HOME/.bashrc"

if cmd-exists startx; then
  if [[ -z "$DISPLAY" ]] && [[ "$XDG_VTNR" = 1 ]] && [[ -z "$TMUX" ]]; then
    exec ssh-agent startx "$HOME/.config/ag/startup/wingo.xinitrc"
  fi
fi
