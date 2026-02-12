# Release Procedure - v1.0.0

## Automated Pre-Release Validation

All releases must pass automated checks before publication:

```bash
# 1. Run full CI/CD pipeline
pre-commit run --all-files

# 2. Verify no secrets in codebase
detect-secrets scan --baseline .secrets.baseline

# 3. Lint playbooks & YAML
ansible-lint stacks.yml monitoring.yml nuke.yml
yamllint .

# 4. Syntax validation
ansible-playbook --syntax-check stacks.yml monitoring.yml nuke.yml
ansible-inventory -i inventory/hosts.ini --list > /dev/null

# 5. Idempotence test (run twice, both should be identical)
ansible-playbook -i inventory/hosts.ini stacks.yml --check --ask-vault-pass
ansible-playbook -i inventory/hosts.ini stacks.yml --check --ask-vault-pass
```

GitHub Actions will automatically validate all pull requests against these checks.

## Manual Release Steps

### 1. Prepare Release Branch
```bash
git checkout main
git pull origin main
git checkout -b release/v1.0.0
```

### 2. Verify Documentation
- [ ] README.md is accurate and NIST claims match implementation
- [ ] ARCHITECTURE.md reflects actual system design
- [ ] CHANGELOG.md documents all changes for this release
- [ ] All links are valid (no broken references)

### 3. Run All Validation (see above)
Complete all automated checks. All must pass before proceeding.

### 4. Create Release Commit
```bash
git commit -m "Release v1.0.0: NIST 800-53 hardening suite

Core Features:
- Automated NIST AC-2, CM-7, SC-7, SI-4, AU-12, SC-28 compliance
- Multi-cloud infrastructure hardening
- Zero-trust Tailscale VPN with ACL automation  
- Portainer Edge Agent management stack
- CrowdSec IDS + auditd monitoring
- Optional observability (VictoriaMetrics, Grafana)

Security Fixes:
- OCI killswitch idempotence verified
- Container privilege isolation (unprivileged users)
- Resource limits enforced across all services
- Deadman switch safety validation

Automation:
- GitHub Actions CI/CD with security gates
- Pre-commit hooks for local validation
- detect-secrets prevents credential commits

See CHANGELOG.md for complete details."

git tag -a v1.0.0 -m "NIST Hardening Suite v1.0.0 - Production Release"
git push origin release/v1.0.0
git push origin v1.0.0
```

### 5. Create GitHub Release
1. Go to Releases → Create New Release
2. Title: `NIST Hardening Suite v1.0.0`
3. Notes: Copy full CHANGELOG.md entry
4. Set as latest release
5. Save & publish

## Post-Release Monitoring

- [ ] Monitor GitHub Issues for early adopter feedback
- [ ] Check GitHub Discussions for user questions
- [ ] Verify security reports arrive via proper channels
- [ ] Plan v1.1.0 improvements based on feedback

## Version Bumping Strategy

Follow semantic versioning:
- **v1.0.1** – Security patches only (no new features)
- **v1.1.0** – New features, backwards compatible
- **v2.0.0** – Major refactor or breaking changes

---

**Note:** All releases require passing GitHub Actions security audit workflow.

