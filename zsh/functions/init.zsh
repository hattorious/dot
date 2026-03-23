#!/usr/bin/env zsh

export DOTFILES=${ZDOTDIR:-${HOME}}/.dotfiles

# =============================================================================
# ZSH FUNCTIONS TOOLKIT LOADER
# =============================================================================
# This file loads all the utility function modules following the repository's
# pattern of common + OS-specific sourcing

# Get the directory where this script is located
local functions_dir="${0:A:h}"

# Load common functions first
if [[ -f "${functions_dir}/common.zsh" ]]; then
  source "${functions_dir}/common.zsh"
fi

# Load OS-specific functions
for os in macos ubuntu; do
  local os_file="${functions_dir}/${os}.zsh"
  if [[ -f "$os_file" ]]; then
    source "$os_file"
  fi
done
