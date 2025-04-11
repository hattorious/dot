#!/usr/bin/env bash
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# Added by OrbStack: command-line tools and integration
source ~/.orbstack/shell/init.bash 2>/dev/null || :
