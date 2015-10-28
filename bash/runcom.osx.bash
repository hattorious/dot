#!/usr/bin/env bash

# only load on OSX
is_osx || return 1

#### EDITOR STUFF
# Make sure Sublime Text's cli is linked
if [[ -f "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" ]]; then
    if [[ ! -L ~/.bin/subl ]]; then
        mkdir -p ~/.bin
        ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" ~/.bin/subl
    fi
fi

# Make 'less' more
[[ "$(type -P lesspipe.sh)" ]] && eval "$(lesspipe.sh)"
