#!/usr/bin/env bash

# only load on freebsd
is_freebsd || return 1

alias cp='cp -i'
alias la='ls -lah'
alias ls='ls -lh'
