#!/usr/bin/env bash

# First we source the basic functions and settings
if [[ -f ~/.dotfiles/bash/init.bash ]]; then
    . ~/.dotfiles/bash/init.bash
fi

#### TERMINAL
export LANG=en_US.UTF-8
export CLICOLOR=1
export LSCOLORS=gxfxcxdxbxegedabagacad

#### PROMPT
# Use liquidprompt, then fallback to .bash_prompt, finally use the inline settings
if [[ -f $DOTFILES/bash/liquidprompt/liquidprompt ]]; then
    # Only load liquidprompt in interactive sessions
    if [[ $- = *i* ]]; then
        . "$DOTFILES/bash/liquidprompt/liquidprompt"
    fi
elif [[ -f ~/.bash_prompt ]]; then
    . ~/.bash_prompt
else
	RESET='\[\e[0m\]'
	BOLD='\[\e[1m\]'
	#YELLOW='\[\e[33m\]'
	BLUE='\[\e[34m\]'
	#BLACK='\[\e[30m\]'
	#RED='\[\e[31m\]'
	#PINK='\[\e[35m\]'
	#CYAN='\[\e[36m\]'
	GREEN='\[\e[32m\]'
	#GRAY='\[\e[37m\]'
	export PS1="$BOLD$GREEN<\u> $BLUE\w\n$RESET$BLUE\$$RESET "
fi


if [[ -f ~/.bash_aliases ]]; then
    . ~/.bash_aliases
fi

# bash completion
if [[ -f "$(brew --prefix)/etc/bash_completion" ]]; then
    . "$(brew --prefix)/etc/bash_completion"
fi

if [[ -f /usr/local/etc/bash_completion.d/git-completion.bash ]]; then
    . /usr/local/etc/bash_completion.d/git-completion.bash;
fi

export PATH=/usr/local/bin:$PATH/sbin:/usr/local/git/bin:/opt/local/bin:$HOME/.bin:
export NODE_PATH=/usr/local/lib/node
export PYTHONPATH=/usr/local/lib/python2.7/site-packages
export ANDROID_SDK_ROOT=/usr/local/Cellar/android-sdk/r18
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.7.0_09.jdk/Contents/Home

# virtualenvwrapper stuff
export WORKON_HOME=$HOME/envs
export PROJECT_HOME=$HOME/projects/python
. /usr/local/bin/virtualenvwrapper.sh

#### EDITOR STUFF
export EDITOR=vim
if [[ -f "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" ]]; then
    if [[ ! -L $HOME/.bin/subl ]]; then
        mkdir -p "$HOME/.bin"
        ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" "$HOME/.bin/subl"
    fi
fi

#### GIT STUFF
alias g='git'
complete -o default -o nospace -F _git g
git config --global color.ui auto
git config --global core.whitespace trailing-space,space-before-tab
git config --global diff.renames copies
git config --global rerere.enabled true
git config --global merge.stat true
git config --global push.default simple

#### NVM
if [[ -f $(brew --prefix nvm)/nvm.sh ]]; then
    export NVM_DIR=~/.nvm
    . "$(brew --prefix nvm)/nvm.sh"
fi
