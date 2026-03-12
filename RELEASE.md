# Release Procedure

Current latest release in git: `v1.3.1`.

This document defines the standard process for all future releases (`v1.3.2+`).

## Automated Pre-Release Validation

All releases must pass automated checks before publication:

```bash
# 1. Run full CI/CD pipeline
uv run pre-commit run --all-files

# 2. Verify no secrets in codebase
uv run detect-secrets scan --baseline .secrets.baseline

# 3. Lint playbooks & YAML
uv run ansible-lint site.yml stacks.yml monitoring.yml nuke.yml
uv run yamllint -c .yamllint .

# 4. Syntax validation
uv run ansible-playbook --syntax-check site.yml
uv run ansible-playbook --syntax-check stacks.yml
uv run ansible-playbook --syntax-check monitoring.yml
uv run ansible-playbook --syntax-check nuke.yml
uv run ansible-inventory -i inventory/hosts.ini --list > /dev/null

# 5. Idempotence test (run twice, both should be identical)
uv run ansible-playbook -i inventory/hosts.ini stacks.yml --check --ask-vault-pass
uv run ansible-playbook -i inventory/hosts.ini stacks.yml --check --ask-vault-pass
```

GitHub Actions will automatically validate all pull requests against these checks.

## Manual Release Steps

### 1. Prepare Release Branch
```bash
git checkout master
git pull origin master
git checkout -b release/vX.Y.Z
```

### 2. Verify Documentation
- [ ] README.md is accurate and NIST claims match implementation
- [ ] ARCHITECTURE.md reflects actual system design
- [ ] CHANGELOG.md documents all changes for this release
- [ ] All links are valid (no broken references)

### 3. Run All Validation (see above)
Complete all automated checks. All must pass before proceeding.

### 4. Create Release Commit and Tag
```bash
git commit -m "Release vX.Y.Z: NIST Hardening Suite

Highlights:
- [add release highlights]
- [add compatibility/security changes]
- [add docs/ops improvements]

Validation:
- Quality gates passed with uv-managed toolchain
- Docs updated (README, ROADMAP, CHANGELOG)

See CHANGELOG.md for full details."

git tag -a vX.Y.Z -m "NIST Hardening Suite vX.Y.Z"
git push origin release/vX.Y.Z
git push origin vX.Y.Z
```

### 5. Create GitHub Release
1. Go to Releases → Create New Release
2. Title: `NIST Hardening Suite vX.Y.Z`
3. Notes: Copy the corresponding `CHANGELOG.md` section
4. Set as latest release
5. Save & publish

## Post-Release Monitoring

- [ ] Monitor GitHub Issues for early adopter feedback
- [ ] Check GitHub Discussions for user questions
- [ ] Verify security reports arrive via proper channels
- [ ] Plan next patch/minor iteration based on feedback

## Version Bumping Strategy

Follow semantic versioning:
- **v1.0.1** – Security patches only (no new features)
- **v1.1.0** – New features, backwards compatible
- **v2.0.0** – Major refactor or breaking changes

---

**Note:** All releases require passing GitHub Actions security audit workflow.

