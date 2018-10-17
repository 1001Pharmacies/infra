CMDS                            ?= ansible ansible-playbook aws docker-exec exec node-exec openstack packer
COMPOSE_IGNORE_ORPHANS          ?= true
COMPOSE_PROJECT_NAME            := $(ENV)_$(APP)
CONTEXT                         += COMPOSE_PROJECT_NAME
DOCKER_SERVICE                  ?= mysql
REMOTE                          ?= ssh://git@github.com/1001Pharmacies/$(SUBREPO)
STACK                           ?= services
STACK_NODE                      ?= node

# force ENV_SYSTEM to refresh COMPOSE_PROJECT_NAME value with $(ENV)_$(APP) instead of $(ENV)_$(ENV_SUFFIX)_$(APP)
ENV_SYSTEM                      := $(shell printenv |awk -F '=' 'NR == FNR { A[$$1]; next } ($$1 in A)' .env.dist - 2>/dev/null |awk '{print} END {print "APP=$(APP)\nBRANCH=$(BRANCH)\nCOMMIT=$(COMMIT)\nCOMPOSE_IGNORE_ORPHANS=$(COMPOSE_IGNORE_ORPHANS)\nCOMPOSE_PROJECT_NAME=$(COMPOSE_PROJECT_NAME)\nENV=$(ENV)\nTAG=$(TAG)"}' |awk -F "=" '!seen[$$1]++')
ifneq (,$(filter true,$(DOCKER)))
ENV_SYSTEM                      := $(patsubst %,-e %,$(ENV_SYSTEM))
endif

ifneq (,$(filter true,$(DRONE)))
SSH_DIR                         := /drone/src/parameters/tests/.ssh
endif

ifeq ($(DOCKER), true)
define ansible
	docker run $(ENV_SYSTEM) --rm -it $(ANSIBLE_ENV) -v $$HOME/.ssh:/root/.ssh:ro -v $$PWD:/pwd -w /pwd ansible $(1)
endef
define ansible-playbook
	docker run $(ENV_SYSTEM) --rm -it --entrypoint /usr/bin/ansible-playbook $(ANSIBLE_ENV) -v $$HOME/.ssh:/root/.ssh:ro -v $$PWD:/pwd -w /pwd ansible $(1)
endef
define aws
	docker run $(ENV_SYSTEM) --rm -it $(AWS_ENV) -v $$HOME/.aws:/root/.aws:ro -v $$PWD:/pwd -w /pwd aws $(1)
endef
define openstack
	docker run $(ENV_SYSTEM) --rm -it $(OPENSTACK_ENV) -v $$PWD:/pwd -w /pwd openstack $(1)
endef
define packer
	docker run $(ENV_SYSTEM) --rm -it --name infra_packer --privileged $(PACKER_ENV) -v /lib/modules:/lib/modules -v $$HOME/.ssh:/root/.ssh -v $$PWD:/pwd -w /pwd packer $(1)
endef
else
define ansible
	$(ENV_SYSTEM) $(ANSIBLE_ENV) ansible $(1)
endef
define ansible-playbook
	$(ENV_SYSTEM) $(ANSIBLE_ENV) ansible-playbook $(1)
endef
define aws
	$(ENV_SYSTEM) $(AWS_ENV) aws $(1)
endef
define openstack
	$(ENV_SYSTEM) $(OPENSTACK_ENV) openstack $(1)
endef
define packer
	$(ENV_SYSTEM) $(PACKER_ENV) packer $(1)
endef
endif
