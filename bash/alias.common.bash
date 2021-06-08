#!/usr/bin/env bash

alias vi='vim'
alias cd..='cd ..'
alias c='clear'


# An overly obvious reference for most commonly requested bash timestamps
function ref_dates() {
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
Nanoseconds only:             | date +%N                   | $(date +%N)
Nanoseconds since UNIX epoch: | date +%s%N                 | $(date +%s%N)
ISO8601 UTC timestamp         | date -u +%FT%TZ            | $(date -u +%FT%TZ)
ISO8601 Local TZ timestamp    | date +%FT%T%Z              | $(date +%FT%T%Z)
EOD
}


# http://stackoverflow.com/questions/3869072/test-for-non-zero-length-string-in-bash-n-var-or-var
# designed to fit an 80 character terminal
# by Dennis Williamson
# shellcheck disable=SC2015,SC2070,SC2086
ref_null_unset() (
    dw=5    # description column width
    w=6     # table column width

    t () { printf "%-${w}s" "true"; }
    f () { [[ $? == 1 ]] && printf "%-${w}s" "false " || printf "%-${w}s" "-err- "; }

    o=/dev/null

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
)

## npm package maintenance
alias patch='pre-version && npm version patch && post-version'
alias minor='pre-version && npm version minor && post-version'
alias major='pre-version && npm version major && post-version'
alias pre-version='git diff --exit-code && npm prune && npm install -q && npm test'
alias post-version='(npm run build; exit 0) && git diff --exit-code && git push && git push --tags && npm publish'


alias serve='python -m SimpleHTTPServer 8888'
alias ppjson='python -m json.tool | less; clear'


# delete all merged branches
alias gdmb='git fetch --prune; git branch --merged | grep -v "\*" | xargs -n 1 git branch -d'
# delete all merged branches from origin
alias gdmbo="git fetch --prune; git branch -r --merged | grep -v -e \/master -e \/main | sed 's/origin\///' | xargs -n 1 git push --delete origin"
# list all hanging branches with commiter name and last commit date
alias branch-blame="git fetch --prune; git for-each-ref --format='%(committername) %09 %(committerdate:short) %09 %(refname:short)' --sort=committerdate --sort=committername | grep -e origin\/ | grep -v -e \/HEAD -e \/master | sed 's/origin\///'"
# cd to root of current git repo
alias gcd='git rev-parse && cd "$(git rev-parse --show-cdup)"'
# various git
alias gsp='git stash pop'
alias gs='git stash'
alias grps='git rev-parse --short'
alias gfp='git fetch --prune'

function read_file() {
    if [[ -f $1 ]]; then
        while IFS= read -r line || [ -n "$line" ]; do echo "$line"; done <"$1"
    fi
    unset IFS
}

function killgpg() {
  if [[ "$(command -v gpg-agent)" ]]; then
      gpgconf --kill gpg-agent;
      gpg-connect-agent --verbose /bye;
  fi
}

function getdrive() {
    local file_id="$1"
    local filename="${2:-$file_id}"
    local cookiejar
    cookiejar=$(mktemp)

    curl --silent --cookie-jar "$cookiejar" --location "https://drive.google.com/uc?export=download&id=${file_id}" > /dev/null
    curl --cookie "$cookiejar" --location "https://drive.google.com/uc?export=download&confirm=$(awk '/download/ {print $NF}' "$cookiejar")&id=${file_id}" --output "./${filename}"
}
