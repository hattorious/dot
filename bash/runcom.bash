#!/usr/bin/env bash

# First we source the basic functions and settings
if [[ -f ~/.dotfiles/bash/init.bash ]]; then
    . ~/.dotfiles/bash/init.bash
fi

#### TERMINAL
export LC_ALL=en_US.UTF-8 
export LANG=en_US.UTF-8
export CLICOLOR=1
export LSCOLORS=gxfxcxdxbxegedabagacad

#### FILES
# files 644 -rw-r--r-- (666 minus 022)
# dirs  755 drwxr-xr-x (777 minus 022)
umask 022

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

# bash completion
if [[ -f "$(brew --prefix)/etc/bash_completion" ]]; then
    . "$(brew --prefix)/etc/bash_completion"
fi

if [[ -f /usr/local/etc/bash_completion.d/git-completion.bash ]]; then
    . /usr/local/etc/bash_completion.d/git-completion.bash;
fi

export PATH=/usr/local/bin:$PATH/sbin:/usr/local/git/bin:/opt/local/bin:~/.bin:

# virtualenvwrapper stuff
export WORKON_HOME=~/envs
. /usr/local/bin/virtualenvwrapper.sh

#### EDITOR STUFF
export EDITOR=vim
export VISUAL="$EDITOR"

#### GIT STUFF
alias g='git'
complete -o default -o nospace -F _git g
git config --global color.ui auto
git config --global core.whitespace trailing-space,space-before-tab
git config --global diff.renames copies
git config --global rerere.enabled true
git config --global merge.stat true
git config --global push.default simple

#### Z
export _Z_DATA=$DOTFILES/tmp/z/z
. "$DOTFILES/bash/z/z.sh"

#### DEFAULTS
# make less always render color codes
export LESS='-r'
# turn off overzealous shellcheck warnings
export SHELLCHECK_OPTS='-e SC1090,SC1091'

#### OS-SPECIFIC FILES
for os in common osx ubuntu; do
    for source in runcom alias; do
        path="$DOTFILES/bash/$source.$os.bash"
        [[ -f "$path" ]] && . "$path"
    done
done

#### LOCAL SETTINGS
if [[ -f ~/.bashrc.local ]]; then
    . ~/.bashrc.local
fi

if [[ -f ~/.bash_aliases.local ]]; then
    . ~/.bash_aliases.local
fi
