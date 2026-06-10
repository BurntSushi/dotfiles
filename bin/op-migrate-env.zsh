#!/usr/bin/env zsh

append() {
  local entry="$1"
  local append="$2"
  { pass show $entry && echo "$append" } \
      | pass insert --multiline --force $entry
}

stale() {
  # local entry="$1"
  for entry; do
    append "$entry" 1STALE
  done
}

fin() {
  local entry="$1"
  append "$entry" 1PASS
}

_entry() {
  local store="${PASSWORD_STORE_DIR:-$HOME/.password-store}"
  local -a entries

  entries=("${store}"/**/*.gpg(N))
  entries=("${entries[@]#$store/}")
  entries=("${entries[@]%.gpg}")

  _describe 'pass entry' entries
}

compdef _entry stale
compdef _entry fin
