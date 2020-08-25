SHELL := /bin/bash
liquidprompt-version := v1.12.0

update: update-liquidprompt

update-liquidprompt:
	git subtree pull --prefix bash/liquidprompt https://github.com/nojhan/liquidprompt.git $(liquidprompt-version) --squash
