#!/usr/bin/env bash

# Let's get started.
echo "init.bash: $BASH_VERSION"
export DOTFILES=~/.dotfiles

function is_interactive_shell() {
  # are we running in an interactive shell?
  [[ $- == *i* ]] || return 1
}

# OS detection
function is_macos() {
    [[ "$OSTYPE" =~ ^darwin ]] || return 1
}

# read the `os-release` file and echo back the passed variable
# https://www.freedesktop.org/software/systemd/man/os-release.html
function read_os() {
  local echovar=${1:-PRETTY_NAME}
  local osrelease
  # first find which file to source
  if [[ -f /etc/os-release ]]; then
    osrelease="/etc/os-release"
  elif [[ -f /usr/lib/os-release ]]; then
    osrelease="/usr/lib/os-release"
  else return 1
  fi

  # now source the file in a subshell to prevent polluting the shell variables of the
  # current shell, and bubble up the variable we're interested in
  echo "$(
    . $osrelease;
    # we don't trust that the sourced file didn't change the PATH
    $(command -v echo) "${!echovar}";
  )"
}

function is_ubuntu() {
  [[ "$(read_os ID)" == "ubuntu" ]] || return 1
}

function get_os() {
    for os in macos ubuntu; do
        is_$os; [[ $? == "${1:-0}" ]] && echo $os
    done
}

## macOS Arch
function is_macos_apple_silicon() {
  is_macos && [[ "$(sysctl -n machdep.cpu.brand_string)" =~ ^Apple ]] || return 1
}
