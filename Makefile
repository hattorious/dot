SHELL := /bin/bash
liquidprompt-version := v2.2.1
bash-complete-alias-version := 1.18.0

include .toolkit/main.mk

## Set up the development environment
init: toolkit-init

.PHONY: init

update: update-liquidprompt update-complete-alias

# to add new subtree:
# git subtree add --prefix <prefix> <git-repo-url> <git-ref> --squash

update-liquidprompt:
	git subtree pull --prefix bash/liquidprompt https://github.com/nojhan/liquidprompt.git $(liquidprompt-version) --squash

update-complete-alias:
	git subtree pull --prefix bash/complete-alias https://github.com/cykerway/complete-alias.git $(bash-complete-alias-version) --squash

.PHONY: update update-liquidprompt update-complete-alias

brewfile:
	brew bundle dump --all --force --describe

.PHONY: brewfile

## Sort all JSON file keys recursively to reduce git diff noise
sort-json:
	fd --extension json \
	    --exclude "vim/vim_runtime/plugins" \
	    --exclude "tmp" \
	    --exclude "dotbot" \
	    --exec-batch uv run scripts/sort_json.py

.PHONY: sort-json
