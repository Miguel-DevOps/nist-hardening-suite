# Contributing to NIST Hardening Suite

Thank you for your interest in contributing. This project follows the Developmi engineering standard.

## Development setup

```bash
# Clone and install
git clone https://github.com/Miguel-DevOps/nist-hardening-suite.git
cd nist-hardening-suite
make sync
make install-collections
make precommit-install
```

## Commit standard

This project uses [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add new endpoint for user authentication
fix: resolve memory leak in connection pool
docs: update README with Docker instructions
chore: bump eslint to v9.x
```

Types: `feat` · `fix` · `docs` · `chore` · `refactor` · `perf` · `test`

Append `!` for breaking changes: `feat!(tailscale): require OAuth credentials for ACL automation`

## Branch naming

```
feat/short-description
fix/issue-number-description
docs/update-readme
chore/bump-dependencies
```

## Pull request process

1. Fork the repository and create your branch from `main`.
2. Ensure validation passes: `make validate && make lint PLAYBOOK=site.yml`
3. Run pre-commit checks: `make precommit-run`
4. Update documentation if your change affects public behavior.
5. Open a PR with a clear title following the commit standard.
6. A maintainer will review within 5 business days.

## Reporting issues

Use [GitHub Issues](https://github.com/Miguel-DevOps/nist-hardening-suite/issues). Include:

- Steps to reproduce
- Expected vs. actual behavior
- Environment (OS, runtime version, Ansible version)

## Extended contribution guide

For Ansible-specific conventions, NIST 800-53 compliance requirements, container security standards, and secret handling procedures, see:

- [docs/project/CONTRIBUTING.md](docs/project/CONTRIBUTING.md)

## Code of conduct

This project adheres to the [Contributor Covenant](https://www.contributor-covenant.org/version/2/1/code_of_conduct/). See [docs/project/CODE_OF_CONDUCT.md](docs/project/CODE_OF_CONDUCT.md).
