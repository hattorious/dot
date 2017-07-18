#!/usr/bin/env bash

# only load on OSX
is_osx || return 1

# bash completion
if [[ -f "$(brew --prefix)/etc/bash_completion" ]]; then
    . "$(brew --prefix)/etc/bash_completion"
fi

# use Homebrew python instead of the system default
export PATH="/usr/local/opt/python/libexec/bin:$PATH"

# Make virtualenvwrapper aware of which python
export VIRTUALENVWRAPPER_PYTHON="/usr/local/opt/python/libexec/bin/python"

# Make 'less' more
[[ "$(type -P lesspipe.sh)" ]] && eval "$(lesspipe.sh)"

# git stuff
git config --global push.default simple

# nodenv
[[ "$(which nodenv)" ]] && export NODENV_ROOT=/usr/local/var/nodenv && eval "$(nodenv init -)"
