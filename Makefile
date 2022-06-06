.POSIX:

.PHONY: help
help:
	@echo 'usage: make [target] ...'
	@echo
	@echo 'Targets Depends Description' | column -t -s ' '
	@echo '------- ------- -----------' | column -t -s ' '
	@egrep '^(.+)\:?.+\ ##\ (.+)' Makefile \
	| column -t -s ':#' | sed 's/Makefile  //'

setup: ## Sets up Virtualenv
    $(shell ./docs/bootstrap/pre-flight)

unit-test: deps ## Runs local unit tests
	@echo Running unit-tests...
        $(shell ./tests/lint/lint-python.sh)
	@echo unit-tests done.

integration-test: deps ## Runs playwright intg tests
	@echo Running integration-tests...
        python3 tests/intg/test_endpoints.py; python3 tests/intg/e2e-state-transition.py
	@echo integration-tests done.

deploy: deps ## Deploys Satsale
        @echo Deploying SatSale...
	gunicorn -w 1 -b 0.0.0.0:8000 satsale:app
	
clean_venv: ## Clears Virtualenv
        virtualenv --clear
	rm -rf .venv
