# shellcheck disable=SC2034,SC2206
# vim: ft=zsh sw=2 ts=2 sts=2

# Define aliases and generic shell variables.
[[ -f ~/.pathrc ]] && . ~/.pathrc
[[ -f ~/.aliasrc ]] && . ~/.aliasrc
[[ -f ~/.envrc ]] && . ~/.envrc

# When doing Astral work, do some custom setup.
if tmux-is-astral; then
  . ~/.astralrc
fi

# If on a work machine, use special initialization.
is-work && [[ -f ~/work/rc/zshrc ]] && . ~/work/rc/zshrc

# Setup umask.
# N.B. kent is a shared system, so use more restrictive umask.
if is-kent; then
  umask 0077
else
  umask 0002
fi

# Don't remove a space before the pipe symbol.
# shellcheck disable=SC2034
ZLE_REMOVE_SUFFIX_CHARS=$' \t\n;&'

# Setup LS_COLORS.
if cmd-exists dircolors; then
  . <(dircolors)
fi

# Set fpath for custom completions.
fpath=(~/.zsh-complete $fpath)
if [[ -f /usr/local/share/zsh-completions ]]; then
  # shellcheck disable=SC2128
  fpath=(/usr/local/share/zsh-completions $fpath)
fi

# Fix for slow git auto-completion. Based on an SO answer, but refined by dana.
# See: https://superuser.com/questions/458906/zsh-tab-completion-of-git-commands-is-very-slow-how-can-i-turn-it-off
__git_other_files() {
  if [[ "$PWD" = "$HOME" ]]; then
    # shellcheck disable=SC2034
    local -a expl
    _wanted files expl 'other file' _files
  fi
}

# Initialize auto completion and expansion.
zstyle ':completion:*' completer _complete _prefix _files
zstyle ':completion:*' menu select=1
zstyle ':completion:*:descriptions' format 'completing %d:'
zstyle ':completion:*' group-name ''
autoload -Uz compinit
# Only check for changes to completion once a day. If you need to force a
# recheck, just delete ~/.zcompdump.
if is-zcompdump-outdated; then
  compinit
else
  compinit -C
fi

# Use Emacs keybindings for now.
bindkey -e

# 'Del' should delete the next char.
bindkey '\e[3~' delete-char
# CTRL-LEFT goes backward one word.
bindkey '\e[1;5D' backward-word
# CTRL-RIGHT goes forward one word.
bindkey '\e[1;5C' forward-word
# Home goes to beginning of line.
bindkey '\e[1~' beginning-of-line
# End goes to end of line.
bindkey '\e[4~' end-of-line
# SHIFT-TAB should go backwards during auto-completion.
bindkey '\e[Z' reverse-menu-complete

# Make it so `command $foo` will potential split "$foo" into multiple
# parameters, which is how most other shells work.
setopt shwordsplit

# When a glob doesn't match anything, pass it through to the command unchanged.
# This is useful for remote globbing, e.g., rsync host:~/foo*.
setopt nonomatch

# Append to the history.
setopt appendhistory
# Use the extended history format, which gives timing info.
setopt extendedhistory
# Append to the history after each command runs, including timing info.
setopt incappendhistorytime
# Do not store adjacent duplicate commands.
setopt histignoredups
# Remove superfluous blanks that sometimes make it into my commands.
setopt histreduceblanks
# Commands beginning with a space are forgotten.
setopt histignorespace

# Notify on the completion of background tasks as soon as they finish, instead
# of waiting for the next prompt.
setopt notify

# Don't remove trailing slashs from directory names.
setopt noautoremoveslash
# When completing an unambiguous prefix, show the completions immediately.
setopt nolistambiguous
# Permit completion to happen inside a word, just before the cursor.
setopt completeinword

# Set history file and limits. Make them huge.
HISTFILE=~/.zsh_history
HISTSIZE=100000000
SAVEHIST=100000000

# Set the the built-in time format to be more like bash, with some goodies.
TIMEFMT=$'\nreal\t%*E\nuser\t%*U\nsys\t%*S\nmaxmem\t%M MB\nfaults\t%F'

# Configure the prompt. We keep things simple for PS1, but expend a bit of
# effort to set the window title correctly.
PS1="[%n@%M %1~]$ "
precmd() {
  cwd="$(pwd)"
  title="${cwd/#$HOME/~}"
  echo -n -e "\e]0;$title\007"
}
preexec() {
  cwd="$(pwd)"
  title="${cwd/#$HOME/~} - $1"
  echo -n -e "\e]0;$title\007"
}
autoload -Uz add-zsh-hook
add-zsh-hook -Uz precmd precmd
add-zsh-hook -Uz preexec preexec

# Enable fzf integration.
if [[ -f ~/.fzf.zsh ]]; then
  . ~/.fzf.zsh
fi

# Enable auto suggestions when typing commands.
zshauto=(
  "$HOME/clones/install/zsh-autosuggestions/zsh-autosuggestions.zsh"
  /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
  /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
)
for p in "${zshauto[@]}"; do
  if [[ -f "$p" ]]; then
    . "$p"
    break
  fi
done
# zsh-autosuggestions recently started enabling "async" retrieval of
# suggestions by default. But in my experience, this actually changes the
# behavior of hitting up-arrow to the point where it actually misses items in
# my history. No clue why, but disabling async reverts zsh-autosuggestions back
# into a working state.
unset ZSH_AUTOSUGGEST_USE_ASYNC

# Enable syntax highlighting in the terminal. This must come last.
zshsyntax=(
  /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
  /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
)
for p in "${zshsyntax[@]}"; do
  if [[ -f "$p" ]]; then
    . "$p"
    break
  fi
done

# Run commands for configuring tty related options.
# We guard this to ensure it won't run for shells
# not connected to a tty.
if [ -t 0 ]; then
  . ~/.zshtty
fi
