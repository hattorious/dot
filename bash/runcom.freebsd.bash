#!/usr/bin/env bash

# only load on freebsd
is_freebsd || return 1

## NODENV
export PATH=$PATH:$HOME/nodenv/bin:
[[ "$(which nodenv)" ]] && export NODENV_ROOT=$HOME/nodenv && eval "$(nodenv init -)"
[[ -f $NODENV_ROOT/completions/nodenv.bash ]] && . "$NODENV_ROOT"/completions/nodenv.bash
