#!/usr/bin/env bash

# git => g
complete -F _complete_alias g

#### COMPLETE ALIAS
if [[ -f $DOTFILES/bash/complete-alias/complete_alias ]]; then
    . "$DOTFILES/bash/complete-alias/complete_alias"
fi

