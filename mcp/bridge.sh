#!/usr/bin/env bash
# ABOUTME: Bridges stdio to a Unix domain socket for MCP server connections.
# ABOUTME: Takes the socket path as its first argument.
[[ -n "$1" ]] || { echo "usage: bridge.sh <socket-path>" >&2; exit 1; }
exec nc -U "$1"
