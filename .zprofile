if command -V startx 2>&1 > /dev/null; then
  if [[ -z "$DISPLAY" ]] && [[ "$XDG_VTNR" = 1 ]] && [[ -z "$TMUX" ]]; then
    . ~/.zshrc
    exec ssh-agent startx "$HOME/.config/ag/startup/wingo.xinitrc"
  fi
fi
