#!/usr/bin/env bash

# only load on OSX
is_osx || return 1

# bash completion
if [[ -f "$(brew --prefix)/etc/bash_completion" ]]; then
    . "$(brew --prefix)/etc/bash_completion"
fi

# editor stuff
# Make sure Sublime Text's cli is linked
if [[ -f "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" ]]; then
    if [[ ! -L ~/.bin/subl ]]; then
        mkdir -p ~/.bin
        ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" ~/.bin/subl
    fi
fi

# Make 'less' more
[[ "$(type -P lesspipe.sh)" ]] && eval "$(lesspipe.sh)"

# git stuff
git config --global push.default simple
