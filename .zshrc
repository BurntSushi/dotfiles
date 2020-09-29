# Define aliases and generic shell variables.
[[ -f ~/.pathrc ]] && . ~/.pathrc
is-work && [[ -f ~/work/rc/pathrc ]] && . ~/work/rc/pathrc
[[ -f ~/.aliasrc ]] && . ~/.aliasrc
is-work && [[ -f ~/work/rc/aliasrc ]] && . ~/work/rc/aliasrc
[[ -f ~/.envrc ]] && . ~/.envrc
is-work && [[ -f ~/work/rc/envrc ]] && . ~/work/rc/envrc

# If on a work machine, use special initialization.
is-work && [[ -f ~/work/rc/zshrc ]] && . ~/work/rc/zshrc

# Setup umask.
# N.B. kent is a shared system, so use more restrictive umask.
if is-kent; then
  umask 0077
else
  umask 0002
fi

# Disable beeping.
setterm --blength 0 > /dev/null 2>&1
# Disable software flow control (Ctrl+Q/Ctrl+S)
# See: https://unix.stackexchange.com/questions/545045/what-is-the-difference-between-ixon-and-ixoff-tty-attributes
stty -ixon

# Don't remove a space before the pipe symbol.
ZLE_REMOVE_SUFFIX_CHARS=$' \t\n;&'

# Setup LS_COLORS.
if cmd-exists dircolors; then
  . <(dircolors)
fi

# Set fpath for custom completions.
fpath=(~/.zsh-complete $fpath)
if [[ -f /usr/local/share/zsh-completions ]]; then
  fpath=(/usr/local/share/zsh-completions $fpath)
fi

# Fix for slow git auto-completion. Based on an SO answer, but refined by dana.
# See: https://superuser.com/questions/458906/zsh-tab-completion-of-git-commands-is-very-slow-how-can-i-turn-it-off
__git_other_files() {
  if [[ "$PWD" = "$HOME" ]]; then
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

# Setup history paging. We bind UP/DOWN to a special variant of history
# searching that matches according to prefix (not just the first word).
# This will also move the cursor to the end of the line.
autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
# UP does history prefix search, backwards.
# DOWN does history prefix search, forwards.
if is-work; then
  # For Ubuntu machines, the normal '\u[A' combo doesn't seem to work for
  # arrow keys. It's not clear why. This formulation was taken from:
  # https://github.com/zsh-users/zsh-history-substring-search/issues/92
  bindkey "$terminfo[kcuu1]" history-beginning-search-backward-end
  bindkey "$terminfo[kcud1]" history-beginning-search-forward-end
else
  bindkey '\e[A' history-beginning-search-backward-end
  bindkey '\e[B' history-beginning-search-forward-end
fi

# CTRL-X CTRL-E edits current command in editor.
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

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
else
  fzf="/usr/share/fzf"
  [[ -d "$fzf" ]] && . "$fzf/key-bindings.zsh" && . "$fzf/completion.zsh"
fi

# Enable auto suggestions when typing commands.
zshauto=(
  /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
  /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  "$HOME/clones/install/zsh-autosuggestions/zsh-autosuggestions.zsh"
)
for p in $zshauto; do
  if [[ -f "$p" ]]; then
    . "$p"
    break
  fi
done

# Enable syntax highlighting in the terminal. This must come last.
zshsyntax=(
  /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
  /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
)
for p in $zshsyntax; do
  if [[ -f "$p" ]]; then
    . "$p"
    break
  fi
done

# Add gvm environment. gvm is used for managing Go installations.
if [[ -f ~/.gvm/scripts/gvm ]]; then
  . ~/.gvm/scripts/gvm
fi

# Try to reconnect to ssh agent?
# if is-work; then
  # if ! ssh-add -L > /dev/null 2>&1; then
    # ssh_reagent
  # fi
# fi
