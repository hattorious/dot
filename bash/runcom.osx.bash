#!/usr/bin/env bash

# only load on OSX
is_osx || return 1

# bash completion
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

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

# pyenv
[[ "$(command -v pyenv)" ]] && eval "$(pyenv init -)"
[[ "$(command -v pyenv-virtualenv-init)" ]] && eval "$(pyenv virtualenv-init -)"

# liquidprompt
export LP_LOAD_THRESHOLD=120

# gpg-agent
[[ "$(command -v gpg-agent)" ]] && gpg-connect-agent /bye
