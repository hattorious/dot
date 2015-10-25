#!/usr/bin/env bash

# only load on ubuntu
is_ubuntu || return 1

alias update="sudo aptitude update"
alias install="sudo aptitude install"
alias upgrade="sudo aptitude safe-upgrade"
alias remove="sudo aptitude remove"
alias ports="sudo netstat -plantu"
