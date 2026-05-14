# Production Command Audit

Operational security checklist for command execution in production environments.

This document is intended for real infrastructure audits where commands are executed sequentially and evidence is collected for validation, compliance, and rollback analysis.

The audit baseline is aligned with the Make-based operational interface and validates that command execution paths are deterministic, tested, and production-safe.

---

## Scope

- Environment: production or production-like
- Interface: Make targets only
- Goal: validate operational command paths before release or post-release hardening
- Audit model: execution + evidence collection
- Exclusions by default:
  - Vault mutation commands
  - Destructive teardown commands

---

## Security Rules Before Running

- Use a trusted control node with MFA-protected access.
- Confirm the active inventory before deployment operations.
- Run dry-run validation before any real apply.
- Preserve full command output for evidence collection and rollback analysis.
- Stop immediately on critical failures and investigate before continuing.

---

## Execution Variables

Recommended operational variables:

```bash id="v2d71a"
ANSIBLE_OPTS='--ask-vault-pass'
ANSIBLE_INVENTORY=inventory/hosts.ini
ANSIBLE_LIMIT=<host_or_group>
```

Additional supported runtime controls:

```bash id="dgs6ux"
APT_FORCE=true
```

When enabled, the Makefile injects:

```text id="1r0v5m"
--extra-vars "apt_force_cleanup=true"
```

This force-cleans stale or locked APT states during automation runs.

---

## Operational Interface Notes

The Make interface now includes:

- Automatic privilege escalation detection
- Automatic become-password prompting when non-root inventory users are detected
- Unified `uv run` execution wrapper for all Ansible commands
- Safer recommended app orchestration with `.env` validation
- Optional forced APT cleanup logic
- Explicit destructive-operation confirmation gates

---

## Audit Checklist

Status legend:

- `[x]` passed
- `[ ]` not executed
- `[!]` failed and requires investigation
- `[-]` intentionally skipped

---

## 1. Environment & Toolchain

- [x] `make help`
- [x] `make sync`
- [x] `make install`
- [x] `make install-collections`
- [x] `make bootstrap`
- [x] `make validate`
- [x] `make precommit-install`
- [x] `make precommit-run`
- [x] `make show-inventory`

---

## 2. Lint & Validation

- [x] `make lint PLAYBOOK=site.yml`
- [x] `make lint PLAYBOOK=stacks.yml`
- [x] `make lint PLAYBOOK=monitoring.yml`

Validation includes:

- `yamllint`
- `ansible-lint`
- strict execution mode through `uv run`

---

## 3. Dry-Run Validation (No Apply)

- [x] `make dry-run PLAYBOOK=site.yml ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make dry-run PLAYBOOK=stacks.yml ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make dry-run PLAYBOOK=monitoring.yml ANSIBLE_OPTS='--ask-vault-pass'`

Dry-run mode executes:

```text id="w5wqai"
--check --diff
```

This validates:

- syntax
- task flow
- templating
- idempotency expectations
- inventory targeting

without mutating infrastructure.

---

## 4. Core Deployment Paths

- [x] `make deploy ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-stacks ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-monitoring ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-custom PLAYBOOK=<file>.yml ANSIBLE_OPTS='--ask-vault-pass'`

Validated playbooks:

| Playbook         | Purpose                                  |
| ---------------- | ---------------------------------------- |
| `site.yml`       | Base hardening and core infrastructure   |
| `stacks.yml`     | Application and ingress stack deployment |
| `monitoring.yml` | Observability and metrics infrastructure |

---

## 5. Tag-Controlled Execution

### Core Infrastructure Tags

- [x] `make deploy-tags PLAYBOOK=site.yml ANSIBLE_TAGS='base,system' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-tags PLAYBOOK=site.yml ANSIBLE_TAGS='security,firewall' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-tags PLAYBOOK=site.yml ANSIBLE_TAGS='crowdsec,ips' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-tags PLAYBOOK=site.yml ANSIBLE_TAGS='vpn,tailscale' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-tags PLAYBOOK=site.yml ANSIBLE_TAGS='docker,containers' ANSIBLE_OPTS='--ask-vault-pass'`

### NIST Control Tags

- [x] `make deploy-tags PLAYBOOK=site.yml ANSIBLE_TAGS='nist' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-tags PLAYBOOK=site.yml ANSIBLE_TAGS='nist,ac-2' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-tags PLAYBOOK=site.yml ANSIBLE_TAGS='nist,cm-7' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-tags PLAYBOOK=site.yml ANSIBLE_TAGS='nist,sc-7' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-tags PLAYBOOK=site.yml ANSIBLE_TAGS='nist,si-4,au-12' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-tags PLAYBOOK=site.yml ANSIBLE_TAGS='nist,sc-28' ANSIBLE_OPTS='--ask-vault-pass'`

### Stack Deployment Tags

- [x] `make deploy-tags PLAYBOOK=stacks.yml ANSIBLE_TAGS='ingress,caddy' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-tags PLAYBOOK=stacks.yml ANSIBLE_TAGS='portainer,management' ANSIBLE_OPTS='--ask-vault-pass'`

### Monitoring & Observability Tags

- [x] `make deploy-tags PLAYBOOK=monitoring.yml ANSIBLE_TAGS='observability,monitoring' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-tags PLAYBOOK=monitoring.yml ANSIBLE_TAGS='exporters' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-tags PLAYBOOK=monitoring.yml ANSIBLE_TAGS='observability_stack' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-tags PLAYBOOK=monitoring.yml ANSIBLE_TAGS='node_exporter' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-tags PLAYBOOK=monitoring.yml ANSIBLE_TAGS='cadvisor' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-tags PLAYBOOK=monitoring.yml ANSIBLE_TAGS='victoriametrics' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-tags PLAYBOOK=monitoring.yml ANSIBLE_TAGS='loki' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-tags PLAYBOOK=monitoring.yml ANSIBLE_TAGS='grafana' ANSIBLE_OPTS='--ask-vault-pass'`

---

## 6. Skip-Tag Validation

- [x] `make deploy-skip-tags PLAYBOOK=site.yml ANSIBLE_SKIP_TAGS='tailscale,vpn' ANSIBLE_OPTS='--ask-vault-pass'`
- [x] `make deploy-skip-tags PLAYBOOK=site.yml ANSIBLE_SKIP_TAGS='security,firewall,fail2ban' ANSIBLE_OPTS='--ask-vault-pass'`

Skip-tag execution confirms selective rollout behavior and safe exclusion paths.

---

## 7. Compliance & Verification

### Compliance Execution

- [x] `make compliance ANSIBLE_OPTS='--ask-vault-pass'`

Validated compliance mode:

```text id="9k8uvk"
--tags compliance
```

---

### Operational Verification Commands

- [x] `make verify-tailscale`
- [x] `make verify-crowdsec`
- [x] `make verify-auditd`
- [x] `make verify-observability`
- [x] `make monitor-crowdsec`

Verification coverage includes:

| Command                | Validation Scope                      |
| ---------------------- | ------------------------------------- |
| `verify-tailscale`     | Mesh VPN connectivity                 |
| `verify-crowdsec`      | IPS alert pipeline                    |
| `verify-auditd`        | Audit logging pipeline                |
| `verify-observability` | Exporters and VictoriaMetrics targets |
| `monitor-crowdsec`     | Local CrowdSec operational monitoring |

---

## 8. Recommended Apps Workflow

- [x] `make recommended-list`
- [x] `make recommended-up`
- [x] `make recommended-down`

### Behavior Validation

The orchestration layer correctly:

- Detects missing `.env` files
- Skips invalid app directories safely
- Prints concise operational warnings
- Avoids long Docker Compose stack traces
- Continues processing remaining valid applications

Expected operator guidance:

```text id="5rln0g"
cp recommended_apps/<app>/.env.example recommended_apps/<app>/.env
```

---

## 9. Vault Operations (Validated but Excluded from Baseline)

The following commands are operationally validated but excluded from routine production audit baselines because they mutate secret material.

- [x] `make vault-init`
- [x] `make vault-encrypt`
- [x] `make vault-edit`
- [x] `make vault-view`

---

## 10. Destructive Operations

The destructive cleanup workflow includes explicit confirmation gates.

Validated command:

- [x] `make nuke CONFIRM=DESTROY_ALL_INFRASTRUCTURE ANSIBLE_OPTS='--ask-vault-pass'`

Safety controls include:

- mandatory confirmation phrase
- explicit operator intent validation
- isolated `nuke.yml` execution path

Required confirmation value:

```text id="jlwm0t"
DESTROY_ALL_INFRASTRUCTURE
```

---

## Operational Safety Guarantees

The current Make interface provides:

- deterministic Ansible execution paths
- enforced inventory selection
- automatic privilege escalation handling
- safer Docker app orchestration
- explicit destructive-operation gating
- optional forced APT recovery controls
- centralized runtime wrapping through `uv run`

---

## Release Gate Statement

If all required commands pass successfully and no critical findings remain unresolved, the operational interface is considered validated for production deployment and ongoing infrastructure maintenance.
