#!make
ifeq ($(UNAME),Darwin)
	SHELL := /opt/local/bin/bash
	OS_X  := true
else ifneq (,$(wildcard /etc/redhat-release))
	OS_RHEL := true
else
	OS_DEB  := true
	SHELL := /bin/bash
endif

PWD := $(shell pwd)
_OK := "\033[32m[%s]\033[0m %s\n" # Green text for "printf"
_KO := "\033[31m[%s]\033[0m %s\n" # Red text for "printf"
.PHONY: help
all: help

create: ## Create cluster
	vagrant up
	vagrant ssh-config > .vagrant/ssh-config
	vagrant ssh ceph-0 -c 'cd /vagrant && sudo ./install-cephadm-config.sh'
	@echo "all done!"
	@echo "Ceph Dashboard is now available at: https://192.168.57.10:8443"
	@grep 'User: ' log-ceph-0
	@grep 'Password: ' log-ceph-0

delete: ## Delete cluster
	vagrant destroy -f

clean: ## Clean env files + logs
	rm -f .vagrant/ssh-config
	rm -f ENV
	rm -f log-ceph-0
	rm -f ceph.pub

up: ## Up (auto create or start)
	@# vagrant up runs "provisions", i.e. vbox customize, again which causes errors
	@if vboxmanage list vms | grep -q vagrant-ceph; then \
	  make start; \
	else \
	  make create; \
	fi

start: ## Start cluster
	while read -r line; \
	do \
	  vboxmanage startvm $$line --type=headless || true; \
	  sleep 1; \
	done < <(vboxmanage list vms | grep vagrant-ceph | cut -d '"' -f 2)

halt:  ## Halt cluster
	@make stop

stop:  ## Stop/halt cluster
	vagrant halt

down: ## Delete and clean
	make delete
	make clean

install-vagrant: ## Install Vagrant on host
	wget -qO - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
	echo "deb [arch=$$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $$(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
	sudo apt update && sudo apt install vagrant


help:
	@## http://www.network-science.de/ascii/ ; Font: poison; Adjustment: left; Width: 120;
	@echo ''
	@echo '       @@@@@@@  @@@@@@@@  @@@@@@@   @@@  @@@  '
	@echo '      @@@@@@@@  @@@@@@@@  @@@@@@@@  @@@  @@@  '
	@echo '      !@@       @@!       @@!  @@@  @@!  @@@  '
	@echo '      !@!       !@!       !@!  @!@  !@!  @!@  '
	@echo '      !@!       @!!!:!    @!@@!@!   @!@!@!@!  '
	@echo '      !!!       !!!!!:    !!@!!!    !!!@!!!!  '
	@echo '      :!!       !!:       !!:       !!:  !!!  '
	@echo '      :!:       :!:       :!:       :!:  !:!  '
	@echo '      ::: :::   :: ::::   ::       ::   :::   '
	@echo '      :: :: :  : :: ::    :         :   : :   '
	@echo ''
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
