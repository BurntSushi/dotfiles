# Check for an interactive session
[ -z "$PS1" ] && return

# Define aliases and generic shell variables.
[[ -f ~/.pathrc ]] && . ~/.pathrc
[[ -f ~/.aliasrc ]] && . ~/.aliasrc
[[ -f ~/.envrc ]] && . ~/.envrc

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

# Various completion and history settings.
set +o ignoreeof
complete -cf sudo
complete -cf man
if complete | grep -q '_rg rg'; then
  complete -r rg
fi
shopt -s histappend
if ! is-mac; then
  shopt -s direxpand
fi

# Setup LS_COLORS.
if command -v dircolors > /dev/null 2>&1; then
  source <(dircolors)
fi

# Configure basic prompt.
ps0() {
  cmd="$(history 1 | cut -d' ' -f2- | xargs -0 echo)"
  cwd="$(pwd)"
  title="${cwd/#$HOME/\~}"
  if [ -n "$cmd" ]; then
    title+=" - $cmd"
  fi
  echo -n -e "\\e]0;$title\\007"
}

prompt_command() {
  if is-mac; then
    return
  fi
  cwd="$PWD"
  title="${cwd/#$HOME/\~}"
  echo -n -e "\\e]0;$title\\007"
}

PS0="\$(ps0)"
PS1="\$(ps1)"
PS1="[\\u@\\h \\W] "
PROMPT_COMMAND="prompt_command"
export PS0 PS1 PROMPT_COMMAND

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
