#!/usr/bin/env zsh

# =============================================================================
# MACOS-SPECIFIC FUNCTIONS
# =============================================================================
# Functions specific to macOS systems and operations

# Only load on macOS
is_macos || return 1

function is_macos_apple_silicon() {
  # Check if the current system is macOS running on Apple Silicon (M1/M2/M3)
  # Returns 0 (true) if Apple Silicon Mac, 1 (false) otherwise
  #
  # Usage:
  #   if is_macos_apple_silicon; then
  #     echo "Running on Apple Silicon Mac"
  #   fi
  #
  # Technical details:
  # - First checks if it's macOS using is_macos function
  # - Uses sysctl to get CPU brand string
  # - Apple Silicon CPUs have brand string starting with "Apple"
  # - Returns 0 for success (Apple Silicon), 1 for failure (Intel or other)
  is_macos && [[ "$(sysctl -n machdep.cpu.brand_string)" =~ ^Apple ]] || return 1
}

function kill_nsurlsessiond() {
  # Kill nsurlsessiond process which can consume excessive bandwidth
  # Unloads the launch daemons and agents responsible for URL session storage
  #
  # Usage:
  #   kill_nsurlsessiond  # Kills the bandwidth-hogging process
  #
  # Technical details:
  # - Uses launchctl to unload system launch daemons and agents
  # - Targets both user and system level processes
  # - Requires sudo for system-level daemon unloading
  # - Useful when experiencing high network usage from system processes
  launchctl unload /System/Library/LaunchDaemons/com.apple.nsurlstoraged.plist
  launchctl unload /System/Library/LaunchAgents/com.apple.nsurlsessiond.plist
  sudo launchctl unload /System/Library/LaunchDaemons/com.apple.nsurlsessiond.plist
  sudo launchctl unload /System/Library/LaunchDaemons/com.apple.nsurlstoraged.plist
}

function dns_over_vpn() {
  # Route DNS queries (8.8.8.8 and 8.8.4.4) through VPN interface
  # Useful when VPN doesn't handle DNS routing properly
  #
  # Usage:
  #   dns_over_vpn  # Routes Google DNS through VPN
  #
  # Technical details:
  # - Adds static routes for Google's DNS servers (8.8.8.8, 8.8.4.4)
  # - Routes through utun0 interface (typical VPN interface on macOS)
  # - Uses route command to add and verify routes
  # - Useful for ensuring DNS queries go through VPN tunnel
  for ip in 8.8.8.8 8.8.4.4; do
    sudo route -n add -net $ip -interface utun0
    route get $ip
  done
}

function brewdepsinstalled() {
  # Check which dependencies of a Homebrew formula are already installed
  # Useful for understanding what will be installed with a formula
  #
  # Arguments:
  #   $1 - Homebrew formula name (required)
  #
  # Usage:
  #   brewdepsinstalled node  # Shows which Node.js dependencies are installed
  #   brewdepsinstalled python  # Shows which Python dependencies are installed
  #
  # Technical details:
  # - Uses join command to find intersection of installed packages and formula dependencies
  # - brew leaves shows packages that are not dependencies of other packages
  # - brew deps shows all dependencies of the specified formula
  # - Useful for understanding Homebrew dependency trees
  local formula=$1

  join <(brew leaves) <(brew deps "$formula")
}
