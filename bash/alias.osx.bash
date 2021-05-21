#!/usr/bin/env bash

# only load on osx
is_osx || return 1


alias cleanup='sudo periodic weekly'
alias cp='cp -i'
alias dream='ssh rhattori@exstasis.net && clear'
alias la='ls -lah'
alias ls='ls -lh'
alias ll='ls -1'
alias mv='mv -i'
alias rm='rm -i'
alias flushdns='dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
alias kexp='mpg123 http://216.246.37.218:80/kexp128.mp3'
alias npr='mpg123 http://streams2.kqed.org:80/kqedradio'

function kill_nsurlsessiond() {
    # nsurlsessiond will eat all your bandwidth, kill it with fire
    launchctl unload /System/Library/LaunchDaemons/com.apple.nsurlstoraged.plist
    launchctl unload /System/Library/LaunchAgents/com.apple.nsurlsessiond.plist
    sudo launchctl unload /System/Library/LaunchDaemons/com.apple.nsurlsessiond.plist
    sudo launchctl unload /System/Library/LaunchDaemons/com.apple.nsurlstoraged.plist
}

function dns_over_vpn() {
    # sometimes you need to resolve a record pointing to a private ip
    for ip in 8.8.8.8 8.8.4.4; do
        sudo route -n add -net $ip -interface utun0;
        route get $ip;
    done
}

function brewdepsinstalled() {
    # `brew rm` can't resolve all deps
    local formula=$1

    join <(brew leaves) <(brew deps "$formula")
}

alias ping="$(command -v prettyping) --nolegend"
alias cat="$(command -v bat)"
alias preview="fzf --preview 'bat --color \"always\" --wrap auto {}'"
