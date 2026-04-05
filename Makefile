SHELL := /usr/bin/env bash

PKG ?= uv
ANSIBLE_INVENTORY ?= inventory/hosts.ini
PLAYBOOK ?= site.yml
ANSIBLE_OPTS ?=
ANSIBLE_LIMIT ?=
ANSIBLE_TAGS ?=
ANSIBLE_SKIP_TAGS ?=
VAULT_FILE ?= group_vars/all/secrets.yml
VAULT_SAMPLE ?= group_vars/all/secrets.yml.example
NUKE_CONFIRM_PHRASE ?= DESTROY_ALL_INFRASTRUCTURE
RECOMMENDED_DIRS := $(shell printf "%s\n" recommended_apps/* 2>/dev/null || true)

BECOME_PROMPT_FLAG := $(shell if [ -f "$(ANSIBLE_INVENTORY)" ]; then \
	awk '/^[[:space:]]*#/ || /^[[:space:]]*$$/ || /^\[/ {next} \
	{user=""; for (i=2; i<=NF; i++) { if ($$i ~ /^ansible_user=/) { split($$i,a,"="); user=a[2]; break } }} \
	user != "" && user != "root" { print "--ask-become-pass"; exit }' "$(ANSIBLE_INVENTORY)"; \
fi)
VAULT_PROMPT_FLAG ?= --ask-vault-pass

.DEFAULT_GOAL := help

.PHONY: help sync install install-collections bootstrap validate lint \
	precommit-install precommit-run show-inventory \
	vault-init vault-encrypt vault-edit vault-view \
	deploy deploy-stacks deploy-monitoring deploy-custom dry-run \
	deploy-tags deploy-skip-tags compliance \
	verify-tailscale verify-crowdsec verify-auditd verify-observability \
	recommended-list recommended-up recommended-down \
	monitor-crowdsec nuke

help:
	@echo "Usage: make <target> [VARIABLE=value]"
	@echo ""
	@echo "Setup:"
	@echo "  sync                 : Sync Python toolchain via $(PKG)"
	@echo "  install              : Alias for sync"
	@echo "  install-collections  : Install Ansible Galaxy collections"
	@echo "  bootstrap            : Run scripts/setup.sh --install"
	@echo "  validate             : Run scripts/setup.sh --validate"
	@echo "  lint                 : Run yamllint + ansible-lint through $(PKG) run (strict)"
	@echo ""
	@echo "Vault:"
	@echo "  vault-init           : Copy secrets example if vault file is missing"
	@echo "  vault-encrypt        : Encrypt $(VAULT_FILE)"
	@echo "  vault-edit           : Edit encrypted $(VAULT_FILE)"
	@echo "  vault-view           : View encrypted $(VAULT_FILE)"
	@echo ""
	@echo "Deploy:"
	@echo "  deploy               : Run site.yml"
	@echo "  deploy-stacks        : Run stacks.yml"
	@echo "  deploy-monitoring    : Run monitoring.yml"
	@echo "  deploy-custom        : Run PLAYBOOK=<file>.yml"
	@echo "  dry-run              : Run PLAYBOOK in check+diff mode"
	@echo "  deploy-tags          : Run PLAYBOOK with ANSIBLE_TAGS=<tags>"
	@echo "  deploy-skip-tags     : Run PLAYBOOK with ANSIBLE_SKIP_TAGS=<tags>"
	@echo "  compliance           : Run site.yml with compliance tag"
	@echo "  become prompt        : auto-enabled when inventory has non-root ansible_user"
	@echo "  note                 : All Ansible executions run through $(PKG) run"
	@echo ""
	@echo "Verification:"
	@echo "  verify-tailscale     : tailscale status on all hosts"
	@echo "  verify-crowdsec      : CrowdSec alerts on all hosts"
	@echo "  verify-auditd        : Tail audit logs on all hosts"
	@echo "  verify-observability : Check exporters and VM targets"
	@echo ""
	@echo "Recommended Apps:"
	@echo "  recommended-list     : List app directories under recommended_apps"
	@echo "  recommended-up       : Start all recommended apps"
	@echo "  recommended-down     : Stop all recommended apps"
	@echo "  note                 : Apps without .env are skipped with one short warning"
	@echo ""
	@echo "Ops:"
	@echo "  monitor-crowdsec     : Run local CrowdSec monitor script"
	@echo "  show-inventory       : Print configured inventory path"
	@echo "  nuke                 : Destructive cleanup (requires explicit confirmation)"

sync:
	@echo "Running $(PKG) sync..."
	$(PKG) sync

install: sync

install-collections:
	@echo "Installing Ansible collections from requirements.yml..."
	$(PKG) run ansible-galaxy collection install -r requirements.yml

bootstrap:
	@echo "Running bootstrap install script..."
	./scripts/setup.sh --install

validate:
	@echo "Running validation (syntax checks)..."
	./scripts/setup.sh --validate

lint:
	@set -e; \
	echo "Running yamllint..."; \
	if ! $(PKG) run yamllint .; then \
		echo "ERROR: yamllint failed. Fix the YAML issues and re-run: make lint PLAYBOOK=$(PLAYBOOK)"; \
		echo "Hint: if the toolchain is missing, run: uv sync"; \
		exit 1; \
	fi; \
	echo "Running ansible-lint on $(PLAYBOOK)..."; \
	if ! $(PKG) run ansible-lint $(PLAYBOOK); then \
		echo "ERROR: ansible-lint failed. Fix the playbook issues and re-run: make lint PLAYBOOK=$(PLAYBOOK)"; \
		echo "Hint: if the toolchain is missing, run: uv sync"; \
		exit 1; \
	fi

precommit-install:
	$(PKG) run pre-commit install

precommit-run:
	$(PKG) run pre-commit run --all-files

show-inventory:
	@test -f $(ANSIBLE_INVENTORY) && cat $(ANSIBLE_INVENTORY) || (echo "Inventory not found: $(ANSIBLE_INVENTORY)" && exit 1)

vault-init:
	@if [ -f "$(VAULT_FILE)" ]; then \
		echo "Vault file already exists: $(VAULT_FILE)"; \
	else \
		cp "$(VAULT_SAMPLE)" "$(VAULT_FILE)"; \
		echo "Created $(VAULT_FILE) from $(VAULT_SAMPLE)."; \
	fi

vault-encrypt:
	@test -f "$(VAULT_FILE)" || (echo "Missing vault file: $(VAULT_FILE)" && exit 1)
	$(PKG) run ansible-vault encrypt "$(VAULT_FILE)"

vault-edit:
	@test -f "$(VAULT_FILE)" || (echo "Missing vault file: $(VAULT_FILE)" && exit 1)
	$(PKG) run ansible-vault edit "$(VAULT_FILE)"

vault-view:
	@test -f "$(VAULT_FILE)" || (echo "Missing vault file: $(VAULT_FILE)" && exit 1)
	$(PKG) run ansible-vault view "$(VAULT_FILE)"

deploy:
	@echo "Deploying base hardening (site.yml)..."
	$(PKG) run ansible-playbook -i $(ANSIBLE_INVENTORY) site.yml $(BECOME_PROMPT_FLAG) $(VAULT_PROMPT_FLAG) $(if $(ANSIBLE_LIMIT),--limit $(ANSIBLE_LIMIT),) $(ANSIBLE_OPTS)

deploy-stacks:
	@echo "Deploying stack services (stacks.yml)..."
	$(PKG) run ansible-playbook -i $(ANSIBLE_INVENTORY) stacks.yml $(BECOME_PROMPT_FLAG) $(VAULT_PROMPT_FLAG) $(if $(ANSIBLE_LIMIT),--limit $(ANSIBLE_LIMIT),) $(ANSIBLE_OPTS)

deploy-monitoring:
	@echo "Deploying observability stack (monitoring.yml)..."
	$(PKG) run ansible-playbook -i $(ANSIBLE_INVENTORY) monitoring.yml $(BECOME_PROMPT_FLAG) $(VAULT_PROMPT_FLAG) $(if $(ANSIBLE_LIMIT),--limit $(ANSIBLE_LIMIT),) $(ANSIBLE_OPTS)

deploy-custom:
	@test -n "$(PLAYBOOK)" || (echo "Set PLAYBOOK=<file>.yml" && exit 1)
	@test -f "$(PLAYBOOK)" || (echo "Playbook not found: $(PLAYBOOK)" && exit 1)
	$(PKG) run ansible-playbook -i $(ANSIBLE_INVENTORY) $(PLAYBOOK) $(BECOME_PROMPT_FLAG) $(VAULT_PROMPT_FLAG) $(if $(ANSIBLE_LIMIT),--limit $(ANSIBLE_LIMIT),) $(ANSIBLE_OPTS)

dry-run:
	@test -f "$(PLAYBOOK)" || (echo "Playbook not found: $(PLAYBOOK)" && exit 1)
	@echo "Running dry-run for $(PLAYBOOK)..."
	$(PKG) run ansible-playbook -i $(ANSIBLE_INVENTORY) $(PLAYBOOK) $(BECOME_PROMPT_FLAG) $(VAULT_PROMPT_FLAG) --check --diff $(if $(ANSIBLE_LIMIT),--limit $(ANSIBLE_LIMIT),) $(ANSIBLE_OPTS)

deploy-tags:
	@test -f "$(PLAYBOOK)" || (echo "Playbook not found: $(PLAYBOOK)" && exit 1)
	@test -n "$(ANSIBLE_TAGS)" || (echo "Set ANSIBLE_TAGS=<tag1,tag2>" && exit 1)
	$(PKG) run ansible-playbook -i $(ANSIBLE_INVENTORY) $(PLAYBOOK) $(BECOME_PROMPT_FLAG) $(VAULT_PROMPT_FLAG) --tags "$(ANSIBLE_TAGS)" $(if $(ANSIBLE_LIMIT),--limit $(ANSIBLE_LIMIT),) $(ANSIBLE_OPTS)

deploy-skip-tags:
	@test -f "$(PLAYBOOK)" || (echo "Playbook not found: $(PLAYBOOK)" && exit 1)
	@test -n "$(ANSIBLE_SKIP_TAGS)" || (echo "Set ANSIBLE_SKIP_TAGS=<tag1,tag2>" && exit 1)
	$(PKG) run ansible-playbook -i $(ANSIBLE_INVENTORY) $(PLAYBOOK) $(BECOME_PROMPT_FLAG) $(VAULT_PROMPT_FLAG) --skip-tags "$(ANSIBLE_SKIP_TAGS)" $(if $(ANSIBLE_LIMIT),--limit $(ANSIBLE_LIMIT),) $(ANSIBLE_OPTS)

compliance:
	@echo "Running compliance audit tag on site.yml..."
	$(PKG) run ansible-playbook -i $(ANSIBLE_INVENTORY) site.yml $(BECOME_PROMPT_FLAG) $(VAULT_PROMPT_FLAG) --tags compliance $(if $(ANSIBLE_LIMIT),--limit $(ANSIBLE_LIMIT),) $(ANSIBLE_OPTS)

verify-tailscale:
	$(PKG) run ansible all -i $(ANSIBLE_INVENTORY) -m command -a "tailscale status"

verify-crowdsec:
	$(PKG) run ansible all -i $(ANSIBLE_INVENTORY) -m shell -a "cscli alerts list"

verify-auditd:
	$(PKG) run ansible all -i $(ANSIBLE_INVENTORY) -m shell -a "tail -n 50 /var/log/audit/audit.log"

verify-observability:
	$(PKG) run ansible all -i $(ANSIBLE_INVENTORY) -m shell -a "docker ps --format '{{.Names}} {{.Status}}' | grep -E 'node-exporter|cadvisor'"
	$(PKG) run ansible all -i $(ANSIBLE_INVENTORY) -m shell -a "curl -fsS http://127.0.0.1:9100/metrics >/dev/null && echo node_exporter_ok"
	$(PKG) run ansible all -i $(ANSIBLE_INVENTORY) -m shell -a "curl -fsS http://127.0.0.1:18080/metrics >/dev/null && echo cadvisor_ok || echo cadvisor_limited_or_down"
	$(PKG) run ansible brain -i $(ANSIBLE_INVENTORY) -m shell -a "curl -fsS 'http://127.0.0.1:8428/api/v1/targets' | grep -E 'node-exporter|cadvisor'"

recommended-list:
	@echo "Recommended apps:"
	@for d in $(RECOMMENDED_DIRS); do \
		if [ -d "$$d" ]; then echo " - $$d"; fi; \
	done

recommended-up:
	@set -e; \
	missing_count=0; \
	missing_names=""; \
	started=0; \
	for d in $(RECOMMENDED_DIRS); do \
		if [ -f "$$d/docker-compose.yml" ] || [ -f "$$d/docker-compose.yaml" ]; then \
			if [ ! -f "$$d/.env" ]; then \
				missing_count=$$((missing_count + 1)); \
				missing_names="$$missing_names $${d##*/}"; \
				continue; \
			fi; \
			echo "Deploying $$d"; \
			( cd "$$d" && docker compose --env-file .env up -d ); \
			started=1; \
		fi; \
	done; \
	if [ "$$missing_count" -gt 0 ]; then \
		echo "WARNING: $$missing_count recommended app(s) are missing .env:$$missing_names"; \
		echo "Fix: cp recommended_apps/<app>/.env.example recommended_apps/<app>/.env and edit the variables."; \
		if [ "$$started" -eq 0 ]; then \
			echo "WARNING: no recommended apps were started because required .env files are missing."; \
		fi; \
	fi

recommended-down:
	@set -e; \
	missing_count=0; \
	missing_names=""; \
	stopped=0; \
	for d in $(RECOMMENDED_DIRS); do \
		if [ -f "$$d/docker-compose.yml" ] || [ -f "$$d/docker-compose.yaml" ]; then \
			if [ ! -f "$$d/.env" ]; then \
				missing_count=$$((missing_count + 1)); \
				missing_names="$$missing_names $${d##*/}"; \
				continue; \
			fi; \
			echo "Stopping $$d"; \
			( cd "$$d" && docker compose --env-file .env down ); \
			stopped=1; \
		fi; \
	done; \
	if [ "$$missing_count" -gt 0 ]; then \
		echo "WARNING: $$missing_count recommended app(s) are missing .env:$$missing_names"; \
		echo "Fix: cp recommended_apps/<app>/.env.example recommended_apps/<app>/.env and edit the variables."; \
		if [ "$$stopped" -eq 0 ]; then \
			echo "WARNING: no recommended apps were stopped because required .env files are missing."; \
		fi; \
	fi

monitor-crowdsec:
	@echo "Running CrowdSec monitor script..."
	./scripts/monitor-crowdsec.sh

nuke:
	@echo "Destructive operation."
	@echo "Required phrase: $(NUKE_CONFIRM_PHRASE)"
	@if [ "$(CONFIRM)" = "$(NUKE_CONFIRM_PHRASE)" ]; then \
		$(PKG) run ansible-playbook -i $(ANSIBLE_INVENTORY) nuke.yml $(BECOME_PROMPT_FLAG) $(VAULT_PROMPT_FLAG) $(if $(ANSIBLE_LIMIT),--limit $(ANSIBLE_LIMIT),) $(ANSIBLE_OPTS); \
	else \
		echo "Aborted. Run with CONFIRM=$(NUKE_CONFIRM_PHRASE) to proceed."; exit 1; \
	fi
