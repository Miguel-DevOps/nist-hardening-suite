# COMMANDS.md

Central command reference for nist-hardening-suite.

This project uses Make as the single operational interface for setup, deployment, validation, and maintenance. Prefer these commands over direct ansible-playbook calls.

Operational rules:

- All Ansible-related execution runs through `uv run`.
- Node-based tooling policy: use `pnpm` only (no `npm`).
- Prettier execution must run through `pnpm` (for example, `pnpm dlx prettier@3.8.1`).
- `make lint` is strict and validates YAML plus the selected playbook.
- Recommended apps without `.env` are skipped with one short warning instead of a long compose failure.

## 1. Help

```bash
make help
```

## 2. Initial Setup

```bash
# Sync local toolchain
make sync

# Install required Ansible collections
make install-collections

# Optional bootstrap workflow
make bootstrap

# Validate local setup and syntax gates
make validate
```

If `make lint` fails because the toolchain is incomplete, restore the environment with `uv sync` and re-run the command.

## 3. Secrets and Vault

```bash
# Create vault file from example if missing
make vault-init

# Encrypt vault file
make vault-encrypt

# Edit encrypted secrets
make vault-edit

# View encrypted secrets
make vault-view
```

Optional variable overrides:

```bash
make vault-edit VAULT_FILE=group_vars/all/secrets.yml
```

## 4. Core Deployments

```bash
# Base hardening (site.yml)
make deploy

# Management stack (stacks.yml)
make deploy-stacks

# Observability stack (monitoring.yml)
make deploy-monitoring
```

Makefile handles prompting automatically in a scalable way:

- If inventory contains a host with `ansible_user` different from `root`, it automatically adds `--ask-become-pass`.
- If all hosts are `root`, it does not add become password prompt.
- Deployment targets include `--ask-vault-pass` by default so encrypted runtime secrets can be decrypted at execution time.

Examples:

```bash
make deploy
```

## 5. Advanced Deployment Controls

```bash
# Dry run any playbook
make dry-run PLAYBOOK=site.yml

# Run a custom playbook
make deploy-custom PLAYBOOK=stacks.yml

# Limit execution to one host or group
make deploy ANSIBLE_LIMIT=brain

# Run specific tags
make deploy-tags PLAYBOOK=site.yml ANSIBLE_TAGS='nist,sc-7'

# Skip specific tags
make deploy-skip-tags PLAYBOOK=site.yml ANSIBLE_SKIP_TAGS='tailscale,vpn'

# Compliance-only run
make compliance
```

Optional override:

```bash
# Disable vault prompt only when encrypted vars are not required
make deploy VAULT_PROMPT_FLAG=
```

## 6. Verification and Monitoring

```bash
# Tailscale status on all hosts
make verify-tailscale

# CrowdSec alerts on all hosts
make verify-crowdsec

# Last audit logs on all hosts
make verify-auditd

# Exporters + scrape target checks
make verify-observability

# Local CrowdSec monitor helper script
make monitor-crowdsec
```

## 7. Quality Gates

```bash
# Lint checks when tools are installed
make lint PLAYBOOK=site.yml

# Install and run pre-commit hooks
make precommit-install
make precommit-run
```

Behavior notes:

- `make lint` is strict and fails on YAML or playbook issues.
- If lint tooling is missing or broken, restore the project environment with `uv sync` and run the command again.
- `make recommended-up` and `make recommended-down` skip any app missing `.env` and print one short warning.
- To fix a recommended app, run `cp recommended_apps/<app>/.env.example recommended_apps/<app>/.env` and update the variables.
- All Ansible commands in this document are executed through `uv run` by the Makefile.

## 8. Recommended Apps

```bash
# List app directories
make recommended-list

# Start all recommended apps
make recommended-up

# Stop all recommended apps
make recommended-down
```

## 9. Inventory and Safety Operations

```bash
# Print active inventory file content
make show-inventory

# Destructive cleanup (guarded by confirmation phrase)
make nuke CONFIRM=DESTROY_ALL_INFRASTRUCTURE
```

Optional variable overrides:

```bash
make deploy ANSIBLE_INVENTORY=inventory/hosts.ini.test
```

## 10. Production Runbook (Recommended Order)

```bash
make sync
make install-collections
make vault-init
make vault-edit
make deploy
make deploy-stacks
make deploy-monitoring
make verify-tailscale
make verify-crowdsec
make verify-observability
```
