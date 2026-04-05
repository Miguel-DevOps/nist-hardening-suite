# Audit Evidence Guide | NIST Hardening Suite

Operational evidence checklist and verification workflow for implementation-grounded compliance reviews.

---

## 1. Evidence Objective

This guide defines how to collect reproducible technical evidence from this repository for security and compliance audits.
It focuses on implemented controls and quality gates, not legal certification language.

---

## 2. Core Evidence Domains

### Control implementation evidence

- Root playbook logic: `site.yml`, `stacks.yml`, `monitoring.yml`, `nuke.yml`.
- Security role behavior: SSH, fail2ban, UFW, kernel hardening, auditd.
- Zero Trust transport assertions for non-bootstrap operations.
- Monitoring and detection behavior from CrowdSec and observability components.

### Configuration evidence

- Inventory group model (`brain`, `muscle`) and host-level variables.
- Global control variables in `group_vars/all`.
- Environment-specific behavior in `group_vars/brain` and `group_vars/muscle`.

### Quality gate evidence

- Ansible lint policy from `.ansible-lint`.
- YAML lint policy from `.yamllint`.
- Pre-commit controls from `.pre-commit-config.yaml`.

---

## 3. Recommended Verification Commands

Use `uv run` to ensure reproducible local tooling paths.

```bash
# Syntax checks for root playbooks
uv run ansible-playbook --syntax-check site.yml
uv run ansible-playbook --syntax-check stacks.yml
uv run ansible-playbook --syntax-check monitoring.yml
uv run ansible-playbook --syntax-check nuke.yml

# Lint policy checks
uv run ansible-lint site.yml stacks.yml monitoring.yml nuke.yml
uv run yamllint -c .yamllint .

# Optional: pre-commit full run
uv run pre-commit run --all-files
```

---

## 4. Runtime Evidence Collection (After Deployment)

```bash
# Tailscale status and node identity
uv run ansible all -i inventory/hosts.ini -m command -a "tailscale status"

# CrowdSec alerts and posture
uv run ansible all -i inventory/hosts.ini -m shell -a "cscli alerts list"

# auditd rules currently active
uv run ansible all -i inventory/hosts.ini -m command -a "auditctl -l"

# Firewall posture
uv run ansible all -i inventory/hosts.ini -m shell -a "ufw status verbose"

# SSH hardening state
uv run ansible all -i inventory/hosts.ini -m shell -a "grep -E '^(PasswordAuthentication|PermitRootLogin|PermitEmptyPasswords)' /etc/ssh/sshd_config"
```

---

## 5. Compliance Role Evidence (Optional)

The `compliance` role runs Lynis and exports daily evidence files under `/var/log/lynis`.

```bash
# Run compliance evidence collection
uv run ansible-playbook -i inventory/hosts.ini site.yml --tags compliance --ask-vault-pass

# Retrieve generated evidence paths
uv run ansible all -i inventory/hosts.ini -m shell -a "ls -lah /var/log/lynis"
```

Expected artifacts include:

- Lynis audit output logs.
- Caddy-related AU-12 evidence export from auditd queries.

---

## 6. Evidence Retention Recommendations

- Keep immutable snapshots of lint outputs per release.
- Store playbook run artifacts with timestamp, commit SHA, and inventory scope.
- Preserve post-deploy security state checks (firewall, auditd, CrowdSec, Tailscale).
- Pair technical evidence with change approval records in your governance workflow.

---

## 7. Limitations

- This evidence guide does not replace external auditor requirements.
- Regulatory acceptance criteria vary by jurisdiction and sector.
- Disk encryption provisioning evidence must come from the infrastructure layer if used for SC-28 extended scope.

---

Maintained by the NIST Hardening Suite project.
