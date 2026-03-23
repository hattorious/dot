#!/usr/bin/env zsh

# =============================================================================
# COMMON UTILITY FUNCTIONS
# =============================================================================
# Functions that work across all operating systems

# =============================================================================
# SHELL AND OS DETECTION FUNCTIONS
# =============================================================================

function is_interactive_shell() {
  # Check if the current shell is running in interactive mode
  # Returns 0 (true) if interactive, 1 (false) if non-interactive
  #
  # Usage:
  #   if is_interactive_shell; then
  #     echo "Running in interactive mode"
  #   fi
  #
  # Technical details:
  # - Uses zsh's -o interactive option to check interactive mode
  # - Returns 0 for success (interactive), 1 for failure (non-interactive)
  [[ -o interactive ]] || return 1
}

function is_macos() {
  # Check if the current system is macOS
  # Returns 0 (true) if macOS, 1 (false) otherwise
  #
  # Usage:
  #   if is_macos; then
  #     echo "Running on macOS"
  #   fi
  #
  # Technical details:
  # - Uses $OSTYPE which contains the operating system type
  # - macOS systems have OSTYPE starting with "darwin"
  # - Pattern matching with =~ operator for regex support
  [[ "$OSTYPE" =~ ^darwin ]] || return 1
}

function read_os() {
  # Read and return a specific variable from the system's os-release file
  # Supports both /etc/os-release and /usr/lib/os-release locations
  #
  # Arguments:
  #   $1 - Variable name to read (default: PRETTY_NAME)
  #
  # Usage:
  #   read_os ID          # Returns "ubuntu", "debian", etc.
  #   read_os PRETTY_NAME # Returns "Ubuntu 22.04.3 LTS"
  #   read_os VERSION_ID  # Returns "22.04"
  #
  # Technical details:
  # - Sources the os-release file in a subshell to avoid polluting current shell
  # - Uses zsh's ${(P)echovar} parameter expansion to get the variable value
  # - Falls back to command -v echo to ensure we use the system echo command
  # - Returns 1 if no os-release file is found
  #
  # Reference: https://www.freedesktop.org/software/systemd/man/os-release.html
  local echovar=${1:-PRETTY_NAME}
  local osrelease

  # Find the os-release file location
  if [[ -f /etc/os-release ]]; then
    osrelease="/etc/os-release"
  elif [[ -f /usr/lib/os-release ]]; then
    osrelease="/usr/lib/os-release"
  else
    return 1
  fi

  # Source the file in a subshell and return the requested variable
  echo "$(
    . $osrelease
    $(command -v echo) "${(P)echovar}"
  )"
}

function is_ubuntu() {
  # Check if the current system is Ubuntu
  # Returns 0 (true) if Ubuntu, 1 (false) otherwise
  #
  # Usage:
  #   if is_ubuntu; then
  #     echo "Running on Ubuntu"
  #   fi
  #
  # Technical details:
  # - Uses read_os function to get the ID from os-release
  # - Compares against "ubuntu" string
  # - Returns 0 for success (Ubuntu), 1 for failure (other OS)
  [[ "$(read_os ID)" == "ubuntu" ]] || return 1
}

function get_os() {
  # Get the current operating system name
  # Returns the OS name (macos, ubuntu) or empty string if not detected
  #
  # Arguments:
  #   $1 - Return value for successful detection (default: 0)
  #
  # Usage:
  #   get_os        # Returns "macos" or "ubuntu" if detected
  #   get_os 1      # Returns OS name if detection succeeds (exit code 0)
  #   os=$(get_os)  # Store OS name in variable
  #
  # Technical details:
  # - Tests each OS detection function in sequence
  # - Uses the provided return value (default 0) for successful detection
  # - Returns empty string if no OS is detected
  local expected_return=${1:-0}

  for os in macos ubuntu; do
    if is_$os; then
      [[ $? == $expected_return ]] && echo $os
    fi
  done
}

# =============================================================================
# ALIAS UTILITY FUNCTIONS
# =============================================================================

alias vi='vim'
alias cd..='cd ..'
alias c='clear'

alias ag='ag --path-to-ignore ~/.ignore --hidden'


# =============================================================================
# DATE AND TIME UTILITY FUNCTIONS
# =============================================================================

function ref_dates() {
  # Display a reference table of common date format patterns and their outputs
  # Useful for quickly finding the right date format for scripts
  #
  # Usage:
  #   ref_dates  # Shows the reference table
  #
  # Technical details:
  # - Uses here-document (cat << EOD) for multi-line output
  # - Each example shows format, command, and actual output
  # - Includes UTC, local timezone, and various precision formats
  # - Useful for scripting and logging purposes
  cat << EOD
        Format/result         |       Command              |          Output
------------------------------+----------------------------+------------------------------
YY-MM-DD_hh:mm:ss             | date +%F_%T                | $(date +%F_%T)
YYMMDD_hhmmss                 | date +%Y%m%d_%H%M%S        | $(date +%Y%m%d_%H%M%S)
YYMMDD_hhmmss (UTC version)   | date -u +%Y%m%d_%H%M%SZ    | $(date -u +%Y%m%d_%H%M%SZ)
YYMMDD_hhmmss (with local TZ) | date +%Y%m%d_%H%M%S%Z      | $(date +%Y%m%d_%H%M%S%Z)
YYMMSShhmmss                  | date +%Y%m%d%H%M%S         | $(date +%Y%m%d%H%M%S)
YYMMSShhmmssnnnnnnnnn         | date +%Y%m%d%H%M%S%N       | $(date +%Y%m%d%H%M%S%N)
Seconds since UNIX epoch:     | date +%s                   | $(date +%s)
Nanoseconds only:             | date +%N                   | $(date +%s%N | tail -c 9)
Nanoseconds since UNIX epoch: | date +%s%N                 | $(date +%s%N)
ISO8601 UTC timestamp         | date -u +%FT%TZ            | $(date -u +%FT%TZ)
ISO8601 Local TZ timestamp    | date +%FT%T%Z              | $(date +%FT%T%Z)
EOD
}

# =============================================================================
# FILE AND SYSTEM UTILITY FUNCTIONS
# =============================================================================

function read_file() {
  # Safely read a file line by line, handling files with or without trailing newline
  # More robust than simple cat for files that might not end with newline
  #
  # Arguments:
  #   $1 - Path to the file to read
  #
  # Usage:
  #   read_file /path/to/file.txt
  #   read_file ~/.config/some.conf
  #
  # Technical details:
  # - Checks if file exists before attempting to read
  # - Uses while loop with IFS= to preserve leading/trailing whitespace
  # - The || [ -n "$line" ] handles files without trailing newline
  # - Unsets IFS after reading to restore default behavior
  if [[ -f $1 ]]; then
    while IFS= read -r line || [ -n "$line" ]; do
      echo "$line"
    done <"$1"
  fi
  unset IFS
}

function getdrive() {
  # Download a file from Google Drive using its file ID
  # Handles Google Drive's download confirmation process
  #
  # Arguments:
  #   $1 - Google Drive file ID (required)
  #   $2 - Output filename (optional, defaults to file ID)
  #
  # Usage:
  #   getdrive "1ABC123DEF456" "myfile.zip"
  #   getdrive "1ABC123DEF456"  # Uses file ID as filename
  #
  # Technical details:
  # - Uses curl with cookie jar to handle Google Drive's download flow
  # - First request gets the download confirmation token
  # - Second request downloads the actual file with the confirmation
  # - Creates temporary cookie jar file that gets cleaned up automatically
  local file_id="$1"
  local filename="${2:-$file_id}"
  local cookiejar
  cookiejar=$(mktemp)

  curl --silent --cookie-jar "$cookiejar" --location "https://drive.google.com/uc?export=download&id=${file_id}" > /dev/null
  curl --cookie "$cookiejar" --location "https://drive.google.com/uc?export=download&confirm=$(awk '/download/ {print $NF}' "$cookiejar")&id=${file_id}" --output "./${filename}"
}

# =============================================================================
# SECURITY AND GPG FUNCTIONS
# =============================================================================

function killgpg() {
  # Kill the GPG agent and force a restart
  # Useful when GPG agent gets stuck or needs to be refreshed
  #
  # Usage:
  #   killgpg  # Kills and restarts GPG agent
  #
  # Technical details:
  # - Checks if gpg-agent command exists before attempting to kill
  # - Uses gpgconf to kill the agent
  # - Uses gpg-connect-agent to ensure the agent is fully stopped
  # - Useful for troubleshooting GPG key issues
  if [[ "$(command -v gpg-agent)" ]]; then
    gpgconf --kill gpg-agent
    gpg-connect-agent --verbose /bye
  fi
}

function yubistub() {
  # Regenerate GPG key stubs for YubiKey
  # Forces GPG to re-learn the YubiKey and update key stubs
  #
  # Usage:
  #   yubistub  # Regenerates YubiKey stubs
  #
  # Technical details:
  # - Uses gpg-connect-agent to interact with the GPG agent
  # - "scd serialno" gets the smart card serial number
  # - "learn --force" forces GPG to re-learn the smart card
  # - Useful when YubiKey is not being recognized properly
  gpg-connect-agent "scd serialno" "learn --force" /bye
}

# =============================================================================
# GIT UTILITY FUNCTIONS
# =============================================================================

function gcd() {
  # Change to the root directory of the current git repository
  # Useful for quickly navigating to the top of a git project
  #
  # Usage:
  #   gcd  # Changes to git repository root
  #
  # Technical details:
  # - Uses git rev-parse to validate we're in a git repository
  # - git rev-parse --show-cdup shows the path to the repository root
  # - Combines validation and navigation in one command
  # - Returns error if not in a git repository
  git rev-parse && cd "$(git rev-parse --show-cdup)"
}

# delete all merged branches
alias gdmb='git fetch --prune; git branch --merged | grep -v "\*" | xargs -n 1 git branch -d'
# delete all merged branches from origin
alias gdmbo='git fetch --prune; git branch -r --merged | grep -v -e /master -e /main -e /develop | sed "s/origin\///" | xargs -n 1 git push --delete origin'
# list all hanging branches with commiter name and last commit date
alias branch-blame='git fetch --prune; git for-each-ref --format="%(committername) %09 %(committerdate:short) %09 %(refname:short)" --sort=committerdate --sort=committername | grep -e origin/ | grep -v -e /HEAD -e /master | sed "s/origin\///"'
# various git
alias gsp='git stash pop'
alias gs='git stash'
alias grps='git rev-parse --short'
alias gfp='git fetch --prune'

# =============================================================================
# DEVELOPMENT UTILITY FUNCTIONS
# =============================================================================

function ref_null_unset() {
  # Display a comprehensive reference table for testing null/unset variables
  # Shows the behavior of different test operators with various variable states
  #
  # Usage:
  #   ref_null_unset  # Shows the reference table
  #
  # Technical details:
  # - Tests various combinations of test operators ([ and [[)
  # - Shows behavior with unset, null, space, and various value types
  # - Uses printf for formatted output
  # - Useful for understanding shell variable testing behavior
  local dw=5    # description column width
  local w=6     # table column width

  t () { printf "%-${w}s" "true"; }
  f () { [[ $? == 1 ]] && printf "%-${w}s" "false " || printf "%-${w}s" "-err- "; }

  local o=/dev/null

  echo '       1a    2a    3a    4a    5a    6a    |1b    2b    3b    4b    5b    6b'
  echo '       [     ["    [-n   [-n"  [-z   [-z"  |[[    [["   [[-n  [[-n" [[-z  [[-z"'

  while read -r d t; do
    printf "%-${dw}s: " "$d"

    case $d in
      unset) unset t  ;;
      space) t=' '    ;;
    esac

    [ $t ]        2>$o  && t || f
    [ "$t" ]            && t || f
    [ -n $t ]     2>$o  && t || f
    [ -n "$t" ]         && t || f
    [ -z $t ]     2>$o  && t || f
    [ -z "$t" ]         && t || f
    echo -n "|"
    [[ $t ]]            && t || f
    [[ "$t" ]]          && t || f
    [[ -n $t ]]         && t || f
    [[ -n "$t" ]]       && t || f
    [[ -z $t ]]         && t || f
    [[ -z "$t" ]]       && t || f
    echo
  done <<'EOF'
unset
null
space
zero    0
digit   1
char    c
hyphn   -z
two     a b
part    a -a
Tstr    -n a
Fsym    -h .
T=      1 = 1
F=      1 = 2
T!=     1 != 2
F!=     1 != 1
Teq     1 -eq 1
Feq     1 -eq 2
Tne     1 -ne 2
Fne     1 -ne 1
EOF
}
