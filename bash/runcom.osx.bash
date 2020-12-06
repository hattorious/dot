#!/usr/bin/env bash

# only load on OSX
is_osx || return 1

# use Homebrew python instead of the system default
export PATH="/usr/local/opt/python/libexec/bin:$PATH"

# Make virtualenvwrapper aware of which python
export VIRTUALENVWRAPPER_PYTHON="/usr/local/opt/python/libexec/bin/python"

# Make 'less' more
export LESSOPEN="|/usr/local/bin/lesspipe.sh %s" LESS_ADVANCED_PREPROCESSOR=1

# nodenv
[[ "$(command -v nodenv)" ]] && export NODENV_ROOT=/usr/local/var/nodenv && eval "$(nodenv init -)"

# pyenv
[[ "$(command -v pyenv)" ]] && eval "$(pyenv init -)"
[[ "$(command -v pyenv-virtualenv-init)" ]] && eval "$(pyenv virtualenv-init -)"

# rbenv
[[ "$(command -v rbenv)" ]] && eval "$(rbenv init -)"

# gpg-agent
[[ "$(command -v gpg-agent)" ]] && gpg-connect-agent /bye

# Hashicorp tools
# Terraform
[[ "$(command -v terraform)" ]] && complete -C "$(command -v terraform)" terraform

# Consul
[[ "$(command -v consul)" ]] && complete -C "$(command -v consul)" consul

# Vault
[[ "$(command -v vault)" ]] && complete -C "$(command -v vault)" vault

# Packer
[[ "$(command -v packer)" ]] && complete -C "$(command -v packer)" packer
