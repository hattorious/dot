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
alias flushdns9='dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
alias flushdns='sudo discoveryutil udnsflushcaches'
alias kexp='mpg123 http://216.246.37.218:80/kexp128.mp3'
alias npr='mpg123 http://streams2.kqed.org:80/kqedradio'

function kill_nsurlsessiond() {
    # nsurlsessiond will eat all your bandwidth, kill it with fire
    launchctl unload /System/Library/LaunchDaemons/com.apple.nsurlstoraged.plist
    launchctl unload /System/Library/LaunchAgents/com.apple.nsurlsessiond.plist
    sudo launchctl unload /System/Library/LaunchDaemons/com.apple.nsurlsessiond.plist
    sudo launchctl unload /System/Library/LaunchDaemons/com.apple.nsurlstoraged.plist
}
