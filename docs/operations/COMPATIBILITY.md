# Operating System Compatibility

## Tested Platforms

The matrix below reflects **field-validated execution**. Each platform has been deployed using the full playbook suite and verified in either production or lab environments.

| Distribution | Codename | Architecture | Status                 | Verified Hosts | Provider      |
| ------------ | -------- | ------------ | ---------------------- | -------------- | ------------- |
| Ubuntu 22.04 | jammy    | amd64        | ✅ Partially Supported | brain & muscle | Hetzner       |
| Ubuntu 22.04 | jammy    | arm64        | ✅ Partially Supported | brain & muscle | Oracle Ampere |
| Ubuntu 24.04 | noble    | amd64        | ✅ Supported           | brain & muscle | Hetzner       |
| Ubuntu 24.04 | noble    | arm64        | ✅ Supported           | brain & muscle | Oracle Ampere |
| Debian 12    | bookworm | amd64        | ✅ Supported           | brain & muscle | Hetzner       |
| Debian 12    | bookworm | arm64        | ✅ Supported           | brain & muscle | Oracle Ampere |
| Debian 13    | trixie   | amd64        | ✅ Supported           | brain & muscle | Hetzner       |
| Debian 13    | trixie   | arm64        | ✅ Supported           | brain & muscle | Oracle Ampere |

## Status Legend

- **✅ Supported** — Full playbook suite (`site.yml`, `stacks.yml`, `monitoring.yml`) validated. Idempotent and production-ready.
- **✅ Partially Supported** — Core deployment path validated (`brain` and `muscle` roles tested successfully), but not every optional stack or edge scenario has completed validation.
- **🔲 Planned** — Repository mappings and package sources exist, but full validation has not yet been completed.
- **⛔ Blocked** — Known incompatibility prevents successful deployment.

---

# Unsupported / Not Actively Tested

| Distribution         | Reason                                                                                 |
| -------------------- | -------------------------------------------------------------------------------------- |
| Ubuntu 20.04 (focal) | End of standard support lifecycle and not aligned with current hardening targets.      |
| Debian 11 (bullseye) | Legacy compatibility may exist, but active validation and maintenance are not planned. |

---

# Architecture Support

Both major Linux server architectures are fully supported:

- **amd64**
  - Primary deployment target.
  - Fully validated on Hetzner and Oracle infrastructure.

- **arm64**
  - Automatically detected through Ansible facts and Docker repository architecture mapping.
  - Fully validated on Oracle Ampere environments.
  - No architecture-specific playbook branching is required outside repository selection logic.

The playbooks rely entirely on Ansible fact gathering for:

- Distribution
- Release codename
- Architecture
- Kernel information

This keeps the deployment flow architecture-agnostic and reduces maintenance complexity.

---

# Known Platform Notes

## Oracle ARM64 Environments

| Issue                           | Impact                                             | Mitigation                                                                                |
| ------------------------------- | -------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| Slow APT mirror synchronization | Initial bootstrap can take significantly longer    | `apt_refresh.yml` already implements retries and extended lock timeouts.                  |
| Oracle-managed firewall rules   | Ports may remain blocked despite UFW configuration | Security role flushes conflicting Oracle rules and applies deadman-switch recovery logic. |

## Debian Minimal Installations

| Issue                        | Impact                                     | Mitigation                                                       |
| ---------------------------- | ------------------------------------------ | ---------------------------------------------------------------- |
| `rsyslog` missing by default | `fail2ban` cannot read authentication logs | Security role installs `rsyslog` automatically during bootstrap. |

---

# User Convention Per OS

`ansible_user` must always be defined per-host inside inventory files and never globally inside `group_vars`.

Example:

```ini
# inventory/hosts.ini

# Debian root-provisioned nodes
debian-node ansible_user=root

# Ubuntu cloud images
ubuntu-node ansible_user=ubuntu

# Custom provisioned systems
custom-node ansible_user=<your_user>
```

The Makefile automatically handles privilege escalation detection through `BECOME_PROMPT_FLAG`.

---

# Adding Support for a New OS

Follow this validation sequence when introducing support for a new Linux distribution or release.

---

## 1. Add Docker Version Mapping

Update:

```yaml
group_vars/all/images.yml
```

Example:

```yaml
docker_version_map:
  Debian:
    bookworm: "5:29.3.0-1~debian.12~bookworm"
    trixie: "5:29.3.0-1~debian.13~trixie"

  Ubuntu:
    jammy: "5:29.3.0-1~ubuntu.22.04~jammy"
    noble: "5:29.3.0-1~ubuntu.24.04~noble"
```

Docker package references:

- Debian: `https://download.docker.com/linux/debian/dists/`
- Ubuntu: `https://download.docker.com/linux/ubuntu/dists/`

---

## 2. Validate CrowdSec Repository Availability

The CrowdSec role dynamically builds repositories using:

- Distribution
- Release codename

Before enabling a new OS, verify repository availability:

```text
https://packagecloud.io/crowdsec/crowdsec/
```

If the codename is unavailable upstream, `apt_repository` tasks will fail.

---

## 3. Validate Tailscale Repository Support

Repository path format:

```text
https://pkgs.tailscale.com/stable/<distro>/<release>
```

Verify the target release exists before deployment.

Reference:

```text
https://pkgs.tailscale.com/stable/
```

---

## 4. Verify WireGuard Kernel Support

Ubuntu systems install extra kernel modules automatically:

```yaml
linux-modules-extra-{{ kernel }}
```

Debian usually ships WireGuard support directly in-kernel.

Validation step:

```bash
modprobe wireguard
```

---

## 5. Validate `distribution_release` Facts

The CrowdSec role requires:

```yaml
distribution_release
```

If Ansible cannot detect the codename on very new distributions:

- Ensure `gather_facts: true`
- Install:

```bash
python3-distro
```

---

## 6. Recommended Validation Sequence

```bash
# Syntax validation
make validate

# Lint checks
make lint PLAYBOOK=site.yml

# Dry-run validation
make dry-run PLAYBOOK=site.yml

# Initial scoped deployment
make deploy-tags PLAYBOOK=site.yml ANSIBLE_TAGS='base,system,packages'

# Full deployment
make deploy

# Idempotency validation
make deploy
```

A successful second run should report:

```text
changed=0
```

---

## 7. Update Compatibility Matrix

After validation completes successfully:

1. Move the OS entry to `✅ Supported`
2. Add tested architectures
3. Add provider validation details
4. Commit documentation updates alongside deployment changes

---

# Contribution Protocol

If you want to contribute new compatibility validations, fixes, or platform support, please follow the repository contribution standards defined in the project CONTRIBUTING guide.

## Development Setup

```bash
git clone https://github.com/Miguel-DevOps/nist-hardening-suite.git

cd nist-hardening-suite

make sync
make install-collections
make precommit-install
```

## Commit Standard

This project follows Conventional Commits:

```text
feat: add Ubuntu 24.04 support
fix: resolve nftables conflict on Debian 13
docs: update compatibility matrix
chore: bump ansible-core version
```

Valid commit types:

- `feat`
- `fix`
- `docs`
- `chore`
- `refactor`
- `perf`
- `test`

Breaking changes:

```text
feat!(security): require signed inventory manifests
```

---

## Branch Naming Convention

```text
feat/add-ubuntu-24-support
fix/debian13-wireguard
docs/update-compatibility
chore/bump-dependencies
```

---

## Pull Request Workflow

1. Fork the repository
2. Create a branch from `main`
3. Run validation:

   ```bash
   make validate && make lint PLAYBOOK=site.yml
   ```

4. Run pre-commit hooks:

   ```bash
   make precommit-run
   ```

5. Update documentation if behavior changes
6. Open a pull request following the commit naming convention

---

## Reporting Issues

Use GitHub Issues and include:

- Steps to reproduce
- Expected behavior
- Actual behavior
- OS and architecture
- Ansible version
- Runtime/container versions

Repository:

```text
https://github.com/Miguel-DevOps/nist-hardening-suite/issues
```

---

## Extended Contribution Guidelines

Additional engineering and compliance documentation:

- `docs/project/CONTRIBUTING.md`
- `docs/project/CODE_OF_CONDUCT.md`

This project follows the Contributor Covenant Code of Conduct.
