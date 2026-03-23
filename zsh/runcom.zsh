# OPENSPEC:START
# OpenSpec shell completions configuration
fpath=("/Users/rhattori/.zsh/completions" $fpath)
autoload -Uz compinit
compinit
# OPENSPEC:END

#!/usr/bin/env zsh

# Source utility functions toolkit
if [[ -f ${ZDOTDIR:-${HOME}}/.dotfiles/zsh/functions/init.zsh ]]; then
  source ${ZDOTDIR:-${HOME}}/.dotfiles/zsh/functions/init.zsh
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

#### ZIM FRAMEWORK
autoload -Uz add-zsh-hook
ZIM_HOME="${DOTFILES}/tmp/zim"
# Download zimfw plugin manager if missing.
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
      https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
fi
# Install missing modules and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
  source /opt/homebrew/opt/zimfw/share/zimfw.zsh init
fi
# Initialize modules.
source ${ZIM_HOME}/init.zsh

#### Z(OXIDE)
# if zoxide is installed then use it
if [[ "$(command -v zoxide)" ]]; then
  export _ZO_DATA_DIR="${DOTFILES}/tmp/zoxide"
  # to import from z: zoxide import --from z path/to/db
fi

#### SENSIBLE
# if [[ -f $DOTFILES/zsh/sensible/sensible.zsh ]]; then
#   source "$DOTFILES/zsh/sensible/sensible.zsh"
# fi

#### PATH
export PATH=$PATH:/sbin:/usr/local/git/bin:/opt/local/bin

#### EDITOR STUFF
export EDITOR=vim
export VISUAL="$EDITOR"

#### GIT STUFF
alias g='git'

#### DEFAULTS
# make less always render color codes
export LESS='-R'
# turn off overzealous shellcheck warnings
export SHELLCHECK_OPTS='-e SC1090,SC1091'
# Turn off Hashicorp checkpointing
export CHECKPOINT_DISABLE=yes


#### OS-SPECIFIC FILES
for os in common macos ubuntu; do
  for source in runcom alias; do
    source_path="$DOTFILES/zsh/$source.$os.zsh"
    [[ -f "$source_path" ]] && source "$source_path"
  done
done

#### POST-OS SETTINGS
if [[ -f ~/.zshrc.post ]]; then
  source ~/.zshrc.post
fi

#### LOCAL SETTINGS
if [[ -f ~/.zshrc.local ]]; then
  source ~/.zshrc.local
fi

# pnpm
export PNPM_HOME="/Users/rhattori/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Added by Spectra
if [[ -z ${path[(r)$HOME/.local/bin]} ]]; then
  path=("$HOME/.local/bin" $path)
fi
