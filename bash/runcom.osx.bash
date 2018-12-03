#!/usr/bin/env bash

# only load on OSX
is_osx || return 1

# bash completion
if [ -f /usr/local/share/bash-completion/bash_completion ]; then
    . /usr/local/share/bash-completion/bash_completion
fi

# use Homebrew python instead of the system default
export PATH="/usr/local/opt/python/libexec/bin:$PATH"

# Make virtualenvwrapper aware of which python
export VIRTUALENVWRAPPER_PYTHON="/usr/local/opt/python/libexec/bin/python"

# Make 'less' more
export LESSOPEN="|/usr/local/bin/lesspipe.sh %s" LESS_ADVANCED_PREPROCESSOR=1

# git stuff
git config --global push.default simple

# nodenv
[[ "$(command -v nodenv)" ]] && export NODENV_ROOT=/usr/local/var/nodenv && eval "$(nodenv init -)"

# liquidprompt
export LP_LOAD_THRESHOLD=120
