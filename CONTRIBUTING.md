# Contributing to NIST-Compliant Hardening Suite

Thank you for your interest in contributing to the NIST-Compliant Hardening Suite! This document provides guidelines and instructions for contributing.

## Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md).

## How to Contribute

### Reporting Bugs
- Use the GitHub Issues tracker.
- Describe the bug in detail: steps to reproduce, expected behavior, actual behavior.
- Include relevant logs, error messages, and system information.

### Suggesting Enhancements
- Open an issue with the "enhancement" label.
- Describe the feature, its use case, and potential implementation approach.

### Submitting Pull Requests
1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/your-feature`).
3. Make your changes, following the code style and conventions.
4. Write or update tests as necessary.
5. Ensure your code passes `ansible-lint` and `yamllint`.
6. Commit your changes with descriptive commit messages.
7. Push to your fork and open a pull request.

## Development Setup

### Prerequisites
- Ansible Core 2.16+
- Python 3.12+
- Docker (for testing container roles)
- Pre-commit hooks
- ansible-lint 6.22+
- yamllint 1.35+

### Local Testing

#### Install Development Environment
```bash
# Install pre-commit hooks (runs linting on every commit)
pip install pre-commit
pre-commit install

# Install linting tools
pip install ansible-core==2.16.0 ansible-lint==6.22.2 yamllint==1.35.1 detect-secrets==1.5.0

# Install Ansible collections  
ansible-galaxy collection install -r requirements.yml
```

#### Run Local Validation
```bash
# Run all pre-commit hooks
pre-commit run --all-files

# OR run individual checks:

# Ansible-lint (playbook quality)
ansible-lint stacks.yml monitoring.yml nuke.yml

# YAML validation
yamllint .

# Secret detection (CRITICAL - prevents accidental secret commits)
detect-secrets scan --baseline .secrets.baseline

# Playbook syntax check
ansible-playbook --syntax-check stacks.yml

# Inventory validation
ansible-inventory -i inventory/hosts.ini --list > /dev/null

# Test playbook structure (dry-run with check mode)
ansible-playbook -i inventory/hosts.ini stacks.yml --check --ask-vault-pass

# Secret Detection Baseline
If detect-secrets reports false positives (e.g., example values in comments), update the baseline:
```bash
detect-secrets scan --baseline .secrets.baseline --all-files
git add .secrets.baseline
```
```

#### Automated Testing with GitHub Actions
All pull requests automatically trigger:
1. **Ansible Lint** - Playbook quality checks
2. **YAML Lint** - YAML syntax and style validation  
3. **Secret Detection** - Prevent credential commits
4. **Security Audit** - NIST 800-53 control verification
5. **Container Scanning** - Docker Compose security practices
6. **Documentation Validation** - Consistency checks

See `.github/workflows/` for workflow definitions.

## Code Style and Conventions

### Ansible Best Practices
- Use `ansible.builtin` modules when possible.
- Keep roles focused and single-purpose.
- Use meaningful variable names with descriptive comments.
- Follow Ansible Galaxy metadata standards.

### YAML Formatting
- Use 2-space indentation.
- Use consistent spacing around colons and dashes.
- Keep line length under 100 characters where possible.

### Documentation
- Update README.md when adding new features.
- Document new variables in `group_vars/all/secrets.yml.example`.
- Include inline comments for complex logic.

## Security Considerations

### Secrets Management (SC-28 Compliance)

**Critical Rule: NEVER commit real secrets to any branch.**

#### Handling Secrets Correctly
```bash
# ❌ WRONG - This exposes the secret
vault_portainer_edge_key: "abcd1234xyz"

# ✅ RIGHT - Use Ansible Vault
ansible-vault encrypt group_vars/all/secrets.yml
# Then reference: {{ vault_portainer_edge_key }} (decrypted at runtime only)
```

#### Secret Detection Automated Protection
This repository uses `detect-secrets` to prevent accidental commits:
- **Local pre-commit hooks** – Block commits with exposed secrets before they reach Git
- **GitHub Actions CI** – Secondary check on every PR
- **`.secrets.baseline`** – Configuration to ignore false positives (e.g., example values in docs)

If you see "Potential secrets detected in commit" error:
1. **Remove the secret** from the file immediately
2. **Use Ansible Vault** to encrypt sensitive data:
   ```bash
   ansible-vault encrypt group_vars/all/secrets.yml --vault-password-file ~/.vault_pass
   ```
3. **Update baseline** if it's a legitimate false positive:
   ```bash
   detect-secrets scan --baseline .secrets.baseline --all-files
   ```

### Critical Requirements
- **Never commit secrets or sensitive data** – detect-secrets runs on every commit
- **Use Ansible Vault** for all encrypted variables (`ansible-vault encrypt`)
- **Validate all inputs** and use secure defaults
- **Follow principle of least privilege** – no root/privileged default containers
- **Idempotence is mandatory** – tasks must produce same result on multiple runs
- **Document security decisions** – explain why choices were made

### NIST 800-53 Compliance
All code contributions must maintain compliance with implemented NIST controls:
- **AC-2** (Account Management): SSH hardening, password policies
- **CM-7** (Least Functionality): Disable unnecessary services/modules
- **SC-7** (Boundary Protection): Firewall rules, network isolation
- **SI-4** (System Monitoring): CrowdSec, auditd required
- **AU-12** (Audit Logging): Comprehensive audit trail
- **SC-28** (Data at Rest): Vault encryption required

### Container Security Standards
- All containers must have `security_opt: [no-new-privileges:true]`
- Docker socket mounts must be read-only (`:ro`)
- Containers should run as unprivileged users (uid 65534 minimum)
- Resource limits must be defined (CPU, memory)
- Never run as root unless architecturally necessary

## Review Process
- All pull requests require at least one maintainer review.
- Changes must pass CI checks (ansible-lint, yamllint).
- Documentation updates are required for new features.
- Breaking changes require major version updates.

## Questions?
Feel free to reach out via GitHub Issues or discussions.

Thank you for helping make this project better!