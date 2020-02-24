##
# COMMON

.PHONY: build
build: $(APPS) ## Build applications

.PHONY: build-%
build-%: $(APPS) ; ## Build applications for (environment)

.PHONY: clean
clean: $(APPS) ## Clean applications

.PHONY: clean-%
clean-%: $(APPS) ; ## Clean applications for (environment)

.PHONY: config
config: $(APPS)

.PHONY: deploy
deploy: $(APPS) ## Deploy applications

.PHONY: deploy-%
deploy-%: $(APPS) ; ## Deploy applications for (environment)

.PHONY: down
down: $(APPS) ## Remove application dockers

.PHONY: ps
ps: $(APPS)

.PHONY: rebuild
rebuild: $(APPS) ## Rebuild applications

.PHONY: recreate
recreate: $(APPS) ## Recreate applications

.PHONY: reinstall
reinstall: $(APPS) ## Reinstall applications

.PHONY: restart
restart: $(APPS) ## Restart applications

.PHONY: start
start: $(APPS) ## Start applications

.PHONY: stop
stop: $(APPS) ## Stop applications

.PHONY: tests
tests: $(APPS) ## Test applications

.PHONY: up
up: $(APPS) ## Create application dockers

.PHONY: $(APPS)
$(APPS): bootstrap-infra docker-infra-base docker-infra-node docker-infra-services
	$(call make,$(patsubst apps-%,%,$(MAKECMDGOALS)) STATUS=0,$(patsubst %/,%,$@),ENV ENV_SUFFIX)

# run targets in $(APPS)
.PHONY: apps-%
apps-%: $(APPS) ; ## run % targets in $(APPS)