docker-sysctl:
	docker run --rm --privileged alpine:latest sysctl -w vm.max_map_count=$(SYSCTL_VM_MAX_MAP_COUNT) >/dev/null

ssh-add:
	docker run --rm --mount source=$(ENV)_$(APP)_ssh-agent,target=/tmp/ssh-agent 1001pharmadev/ssh-agent:latest ssh-add -l >/dev/null \
		|| docker run --rm --mount source=$(ENV)_$(APP)_ssh-agent,target=/tmp/ssh-agent -v $(SSH_PRIVATE_KEY):/root/.ssh/id_rsa -it 1001pharmadev/ssh-agent:latest ssh-add /root/.ssh/id_rsa
