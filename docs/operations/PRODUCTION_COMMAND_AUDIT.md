# Production Command Audit

Operational security checklist for command execution in production.

This document is designed for real infrastructure audits where commands are executed one by one and evidence is collected. It is aligned with the Make-based command interface and helps operators verify that command paths are tested, predictable, and safe.

## Scope

- Environment: production or production-like
- Interface: Make targets only
- Goal: prove operational command paths before release or post-release hardening
- Exclusions by default: Vault mutation commands and destructive teardown commands

## Security Rules Before Running

- Run from a trusted control node with MFA-protected access.
- Confirm active inventory before any deployment command.
- Run dry-run checks before real apply.
- Keep full command output for evidence and rollback analysis.
- Stop on first critical failure and investigate before continuing.

## Execution Variables

Use these variables consistently in commands when needed:

- `ANSIBLE_OPTS='--ask-vault-pass'`
- `ANSIBLE_INVENTORY=inventory/hosts.ini` (or your explicit inventory)
- `ANSIBLE_LIMIT=<host_or_group>` for scoped rollouts

## Audit Checklist

Status legend:

- `[ ]` not run
- `[x]` passed
- `[!]` failed and requires investigation
- `[-]` intentionally skipped

### 1. Preflight (No Infra Changes)

- [x] `make help`
- [x] `make show-inventory`
- [-] `make validate` (Use a clean checkout and ensure `scripts/setup.sh` is executable before running)
- [x] `make lint PLAYBOOK=site.yml`
- [x] `make lint PLAYBOOK=stacks.yml`
- [x] `make lint PLAYBOOK=monitoring.yml`

### 2. Dry Run (No Apply)

- [x] `make dry-run PLAYBOOK=site.yml ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make dry-run PLAYBOOK=stacks.yml ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make dry-run PLAYBOOK=monitoring.yml ANSIBLE_OPTS='--ask-vault-pass'`

### 3. Real Apply (Core Paths)

- [x] `make deploy ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-stacks ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-monitoring ANSIBLE_OPTS='--ask-vault-pass'`

### 4. Tag-Controlled Execution

- [x] `make deploy-tags PLAYBOOK=site.yml ANSIBLE_TAGS='base,system' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-tags PLAYBOOK=site.yml ANSIBLE_TAGS='security,firewall' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-tags PLAYBOOK=site.yml ANSIBLE_TAGS='crowdsec,ips' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-tags PLAYBOOK=site.yml ANSIBLE_TAGS='vpn,tailscale' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-tags PLAYBOOK=site.yml ANSIBLE_TAGS='docker,containers' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-tags PLAYBOOK=site.yml ANSIBLE_TAGS='nist' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-tags PLAYBOOK=site.yml ANSIBLE_TAGS='nist,ac-2' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-tags PLAYBOOK=site.yml ANSIBLE_TAGS='nist,cm-7' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-tags PLAYBOOK=site.yml ANSIBLE_TAGS='nist,sc-7' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-tags PLAYBOOK=site.yml ANSIBLE_TAGS='nist,si-4,au-12' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-tags PLAYBOOK=site.yml ANSIBLE_TAGS='nist,sc-28' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-tags PLAYBOOK=stacks.yml ANSIBLE_TAGS='ingress,caddy' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-tags PLAYBOOK=stacks.yml ANSIBLE_TAGS='portainer,management' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-tags PLAYBOOK=monitoring.yml ANSIBLE_TAGS='observability,monitoring' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-tags PLAYBOOK=monitoring.yml ANSIBLE_TAGS='exporters' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-tags PLAYBOOK=monitoring.yml ANSIBLE_TAGS='observability_stack' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-tags PLAYBOOK=monitoring.yml ANSIBLE_TAGS='node_exporter' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-tags PLAYBOOK=monitoring.yml ANSIBLE_TAGS='cadvisor' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-tags PLAYBOOK=monitoring.yml ANSIBLE_TAGS='victoriametrics' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-tags PLAYBOOK=monitoring.yml ANSIBLE_TAGS='loki' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-tags PLAYBOOK=monitoring.yml ANSIBLE_TAGS='grafana' ANSIBLE_OPTS='--ask-vault-pass'`

### 5. Skip-Tag Controls

- [x] `make deploy-skip-tags PLAYBOOK=site.yml ANSIBLE_SKIP_TAGS='tailscale,vpn' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-skip-tags PLAYBOOK=site.yml ANSIBLE_SKIP_TAGS='security,firewall,fail2ban' ANSIBLE_OPTS='--ask-vault-pass'`

### 6. Compliance and Verification

- [x] `make compliance ANSIBLE_OPTS='--ask-vault-pass'`
- [!] `make verify-tailscale`
- [!] `make verify-crowdsec`
- [!] `make verify-auditd`
- [!] `make verify-observability`
- [!] `make monitor-crowdsec`

### 7. Recommended Apps (Optional)

- [x] `make recommended-list`
- [x] `make recommended-up`
- [x] `make recommended-down`

Behavior note:

- `make recommended-up` and `make recommended-down` print a clear alert and skip any app missing `.env` instead of failing with a long `docker compose` error.

## Explicitly Skipped in This Audit Baseline

- `make vault-init`
- `make vault-encrypt`
- `make vault-edit`
- `make nuke CONFIRM=DESTROY_ALL_INFRASTRUCTURE ANSIBLE_OPTS='--ask-vault-pass'`

Reason: these commands mutate secret material or perform destructive teardown and are not part of routine production command-path validation.

## Release Gate Statement

If all required commands pass and no critical findings remain open, command integration is considered validated for production use.
