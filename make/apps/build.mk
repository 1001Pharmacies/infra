##
# BUILD

.PHONY: build@%
build@%: infra-base ## Build application docker images to deploy
	$(eval DRYRUN_IGNORE   := true)
	$(eval SERVICES        ?= $(shell $(call docker-compose,--log-level critical config --services)))
	$(eval DRYRUN_IGNORE   := false)
	$(eval docker_images   += $(foreach service,$(SERVICES),$(if $(shell docker images -q $(DOCKER_REPOSITORY)/$(service):$(DOCKER_IMAGE_TAG) 2>/dev/null),$(service))))
	$(eval build_app       := $(or $(filter $(DOCKER_BUILD_CACHE),false),$(filter-out $(docker_images),$(SERVICES))))
	$(if $(build_app),$(call make,build-app),$(if $(filter $(VERBOSE),true),$(foreach service,$(SERVICES),echo "docker image $(DOCKER_REPOSITORY)/$(service):$(DOCKER_IMAGE_TAG) has id $(shell docker images -q $(DOCKER_REPOSITORY)/$(service):$(DOCKER_IMAGE_TAG) 2>/dev/null)" &&) true))

.PHONY: build-env
build-env: SERVICE ?= $(DOCKER_SERVICE)
build-env: bootstrap
	$(call docker-compose-exec,$(SERVICE),rm -f .env && make .env ENV=$(ENV) && echo BUILD=true >> .env && echo BUILD_DATE='"\'"'$(shell date "+%d/%m/%Y %H:%M:%S %z" 2>/dev/null)'"\'"' >> .env && echo BUILD_STATUS='"\'"'$(shell git status -uno --porcelain 2>/dev/null)'"\'"' >> .env && echo DOCKER=false >> .env && $(foreach var,$(BUILD_APP_VARS),$(if $($(var)),sed -i '/^$(var)=/d' .env && echo $(var)='$($(var))' >> .env &&)) true)

.PHONY: build-rm
build-rm:
	$(call exec,rm -rf build && mkdir -p build)

.PHONY: build-$(SHARED)
build-$(SHARED): SERVICE ?= $(DOCKER_SERVICE)
build-$(SHARED): bootstrap
	$(call docker-compose-exec,$(SERVICE),mkdir -p /$(SHARED) && $(foreach folder,$(SHARED_FOLDERS),rm -rf $(folder) && mkdir -p $(dir $(folder)) && ln -s /$(SHARED)/$(notdir $(folder)) $(folder) &&) true)
