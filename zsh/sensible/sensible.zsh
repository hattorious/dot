# Sensible Zsh - An attempt at saner Zsh defaults
# Based on: https://github.com/mrzool/bash-sensible
# Translated and adapted for zsh

## GENERAL OPTIONS ##

# Prevent file overwrite on stdout redirection
# Use `>|` to force redirection to an existing file
setopt NO_CLOBBER

# Update window size after every command
# zsh handles this automatically, but we can be explicit
# (zsh doesn't have an equivalent to shopt -s checkwinsize)

# Automatically trim long paths in the prompt
# zsh has built-in prompt expansion for this
# %2~ will show only the last 2 components of the path

# Enable history expansion with space
# E.g. typing !!<space> will replace the !! with your last command
bindkey ' ' magic-space

# Turn on recursive globbing (enables ** to recurse all directories)
setopt GLOB_STAR_SHORT

# Case-insensitive globbing (used in pathname expansion)
setopt NO_CASE_GLOB

## SMARTER TAB-COMPLETION ##

# Perform file completion in a case insensitive fashion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Treat hyphens and underscores as equivalent
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}'

# Display matches for ambiguous patterns at first tab press
setopt MENU_COMPLETE

# Immediately add a trailing slash when autocompleting symlinks to directories
setopt AUTO_PARAM_SLASH

# Enable menu selection for completions
zstyle ':completion:*' menu select

# Use cache for completions
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path ~/.zsh/cache

## SANE HISTORY DEFAULTS ##

# Append to the history file, don't overwrite it
setopt APPEND_HISTORY

# Save multi-line commands as one command
setopt EXTENDED_HISTORY

# Record each line as it gets issued
# zsh handles this automatically with INC_APPEND_HISTORY
setopt INC_APPEND_HISTORY

# Huge history. Doesn't appear to slow things down, so why not?
HISTSIZE=500000
SAVEHIST=100000

# Avoid duplicate entries
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_DUPS

# Don't record some commands
HISTORY_IGNORE="(exit|ls|bg|fg|history|clear|cd|pwd|* --help)"

# Use standard ISO 8601 timestamp
# zsh uses a different format for history timestamps
# This is handled by the prompt or history display

# Enable incremental history search with up/down arrows
# zsh has built-in history search
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward

# Additional history search bindings for different terminal types
bindkey '^P' history-beginning-search-backward
bindkey '^N' history-beginning-search-forward

## BETTER DIRECTORY NAVIGATION ##

# Prepend cd to directory names automatically
setopt AUTO_CD

# Correct spelling errors during tab-completion
setopt CORRECT

# Correct spelling errors in arguments supplied to cd
setopt CORRECT_ALL

# This defines where cd looks for targets
# Add the directories you want to have fast access to, separated by colon
# Ex: cdpath=(. ~ ~/projects) will look for targets in the current working directory, in home and in the ~/projects folder
cdpath=(.)

# This allows you to bookmark your favorite places across the file system
# Define a variable containing a path and you will be able to cd into it regardless of the directory you're in
# zsh has built-in support for this with named directories
# Examples:
# hash -d dotfiles="$HOME/dotfiles"
# hash -d projects="$HOME/projects"
# hash -d documents="$HOME/Documents"
# hash -d dropbox="$HOME/Dropbox"

## ADDITIONAL ZSH-SPECIFIC IMPROVEMENTS ##

# Enable extended globbing
setopt EXTENDED_GLOB

# Don't beep on error
setopt NO_BEEP

# Allow comments in interactive shells
setopt INTERACTIVE_COMMENTS

# Share history between different instances of the shell
setopt SHARE_HISTORY

# Don't save commands that start with a space
setopt HIST_IGNORE_SPACE

# Remove superfluous blanks from each command line being added to the history list
setopt HIST_REDUCE_BLANKS

# Don't execute immediately upon history expansion
setopt HIST_VERIFY

# Better word splitting
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_MINUS

# Better job control
setopt AUTO_CONTINUE
setopt NOTIFY

# Better completion
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END

# Better globbing
setopt NUMERIC_GLOB_SORT

# Better brace expansion
setopt BRACE_CCL

# Better parameter expansion
setopt RC_EXPAND_PARAM

# Better array handling
setopt KSH_ARRAYS

# Better function handling
setopt LOCAL_OPTIONS
setopt LOCAL_TRAPS

# Better error handling
setopt ERR_EXIT
setopt NO_UNSET

# Better prompt handling
setopt PROMPT_SUBST
setopt TRANSIENT_RPROMPT

# Better directory stack
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_MINUS

# Better completion system
autoload -Uz compinit
compinit

# Better history search
autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
