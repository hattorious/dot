#!/usr/bin/env bash

alias vi='vim'
alias cd..='cd ..'
alias c='clear'


# An overly obvious reference for most commonly requested bash
# timestamps
function dates() {
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


## npm package maintenance
alias patch='pre-version && npm version patch && post-version'
alias minor='pre-version && npm version minor && post-version'
alias major='pre-version && npm version major && post-version'
alias pre-version='git diff --exit-code && npm prune && npm install -q && npm test'
alias post-version='(npm run build; exit 0) && git diff --exit-code && git push && git push --tags && npm publish'


alias serve='python -m SimpleHTTPServer 8888'
alias ppjson='python -m json.tool | less; clear'


# delete all merged branches
alias gdmb='git branch --merged | grep -v "\*" | xargs -n 1 git branch -d'
# delete all merged branches from origin
alias gdmbo="git branch -r --merged | grep -v -e \/master | sed 's/origin\///' | xargs -n 1 git push --delete origin"
# list all hanging branches with commiter name and last commit date
alias branch-blame="git for-each-ref --format='%(committername) %09 %(committerdate:short) %09 %(refname:short)' --sort=committerdate --sort=committername | grep -e origin\/ | grep -v -e \/HEAD -e \/master | sed 's/origin\///'"
# cd to root of current git repo
alias gcd='git rev-parse && cd "$(git rev-parse --show-cdup)"'
