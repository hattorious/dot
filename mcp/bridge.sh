#!/usr/bin/env bash
# ABOUTME: Bridges stdio to a Unix domain socket for MCP server connections.
# ABOUTME: Takes the socket path as its first argument.
exec nc -U "$1"
