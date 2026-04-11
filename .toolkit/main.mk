# Utility functions and targets for Makefile

# For self-documenting of Makefile: use '##' before target to provide a description
#
# References:
# https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
# https://github.com/drivendata/cookiecutter-data-science/blob/master/%7B%7B%20cookiecutter.repo_name%20%7D%7D/Makefile
#
# sed script explained:
# /^##/:
# 	* save line in hold space
# 	* purge line
# 	* Loop:
# 		* append newline + line to hold space
# 		* go to next line
# 		* if line starts with doc comment, strip comment character off and loop
# 	* remove target prerequisites
# 	* append hold space (+ newline) to line
# 	* replace newline plus comments by `---`
# 	* print line
# Separate expressions are necessary because labels cannot be delimited by
# semicolon; see <http://stackoverflow.com/a/11799865/1968>
#
## Show this message
help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)"
	@echo
	@sed -n -e "/^## / { \
		h; \
		s/.*//; \
		:doc" \
		-e "H; \
		n; \
		s/^## //; \
		t doc" \
		-e "s/:.*//; \
		G; \
		s/\\n## /---/; \
		s/\\n/ /g; \
		p; \
	}" ${MAKEFILE_LIST} \
	| LC_ALL='C' sort --ignore-case \
	| awk -F '---' \
		-v ncol=$$(tput cols) \
		-v indent=30 \
		-v col_on="$$(tput setaf 6)" \
		-v col_off="$$(tput sgr0)" \
	'{ \
		printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
		n = split($$2, words, " "); \
		line_length = ncol - indent; \
		for (i = 1; i <= n; i++) { \
			line_length -= length(words[i]) + 1; \
			if (line_length <= 0) { \
				line_length = ncol - indent - length(words[i]) - 1; \
				printf "\n%*s ", -indent, " "; \
			} \
			printf "%s ", words[i]; \
		} \
		printf "\n"; \
	}' \
	| more $(shell test $(shell uname) = Darwin && echo '--no-init --raw-control-chars')

.PHONY: help

toolkit-init: toolkit-init-homebrew toolkit-init-python toolkit-init-pre-commit

.PHONY: toolkit-init

toolkit-init-homebrew:
	@brew bundle --file=.toolkit/Brewfile
	@echo "Dotfiles toolkit: homebrew dependencies initialized"

toolkit-init-python:
	@uv sync --dev
	@echo "Dotfiles toolkit: python dependencies initialized"

toolkit-init-pre-commit:
	@pre-commit install --install-hooks
	@echo "Dotfiles toolkit: pre-commit hooks initialized"

.PHONY: toolkit-init-homebrew toolkit-init-python toolkit-init-pre-commit
