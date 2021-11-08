SHELL := /bin/bash
liquidprompt-version := v2.0.3
bash-complete-alias-version := 1.18.0

update: update-liquidprompt update-complete-alias

## to add new subtree:
# git subtree add --prefix <prefix> <git-repo-url> <git-ref> --squash

update-liquidprompt:
	git subtree pull --prefix bash/liquidprompt https://github.com/nojhan/liquidprompt.git $(liquidprompt-version) --squash

update-complete-alias:
	git subtree pull --prefix bash/complete-alias https://github.com/cykerway/complete-alias.git $(bash-complete-alias-version) --squash
