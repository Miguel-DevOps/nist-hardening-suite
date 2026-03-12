# Changelog

All notable changes to NIST Hardening Suite are documented here.

## [1.3.0] - 2026-03-12

### Highlights
- **Security hardening**: Fixed Docker bridge network range (`172.16.0.0/12`), dynamic fail2ban IP whitelist, and removed obsolete SSH `Protocol` directive.
- **Tailscale auth key hardening**: Auth key now passed via stdin (`--authkey=-`) to prevent process list exposure (CWE-214).
- **Portainer Edge Agent improvements**: Added `no_log` guards, dynamic Edge ID resolution with machine-identity fallback, secure `/tmp` tmpfs mount, and YAML dict environment format.
- **New configurable variables**: `ufw_enable_ipv6` (dual-stack UFW control), `tailscale_enable_webclient` (persistent webclient toggle).
- **Toolchain migration to `uv`**: Pinned Python 3.14, upgraded to `ansible-core 2.20.3`, `ansible-lint 26.3.0`, `yamllint 1.38.0`; added `pyproject.toml` for reproducible environments.
- **Linting improvements**: Updated `.yamllint` rules, fixed `ansible-lint` file pattern in pre-commit, added `.venv/` to `.gitignore`.

### Notes
- All security fixes are backwards-compatible. Existing deployments require no variable changes.
- `uv sync` is now the recommended way to install the local toolchain.
- Docker bridge range fix corrects a previously over-permissive UFW rule.

## [1.2.0] - 2026-03-08

### Highlights
- **Portainer hardening**: Added TLS server certificate flow and stronger Edge Agent deployment defaults.
- **Tailscale ACL improvements**: Introduced composable ACL source groups and break-glass policy patterns.
- **Observability reliability**: Fixed base directory handling and normalized Ansible builtin module usage.
- **Documentation alignment**: Standardized Portainer key naming and pinned `caddy-waf` image tag in docs.

### Notes
- This release builds on `v1.1.0` and keeps the NIST control baseline intact.
- Main objective: improve operational reliability and secure defaults without changing architecture scope.

## [1.1.0] - 2026-03-08

### Highlights
- **Runtime compatibility updates** for container and Ansible ecosystem changes.
- **Security hardening expansion** in core roles and CrowdSec reliability paths.
- **Docker runtime improvements** including Docker 29 compatibility and cAdvisor updates.
- **Tailscale enrollment hardening** with improved ACL policy generation.
- **Repository/docs cleanup** for better operational consistency.

### Notes
- Focused on stability, compatibility, and hardening continuity after `v1.0.0`.

## [1.0.0] - 2026-02-12

### 🚀 First Production Release

Initial public release of the NIST Hardening Suite with full NIST 800-53 compliance automation.

#### Core Features
- **Automated NIST 800-53 compliance** across 6 security control families
- **Multi-cloud support** – Oracle Cloud, Hetzner, AWS, GCP, Azure
- **Zero-trust networking** – Tailscale VPN mesh with automated ACL enforcement
- **Container orchestration** – Portainer Edge Agent (pull-based, no exposed ports)
- **Reverse proxy & WAF** – Caddy with VPN-only access restrictions
- **Security monitoring** – CrowdSec IDS, auditd comprehensive logging
- **Optional observability** – VictoriaMetrics, Grafana, Uptime Kuma (monitoring.yml)
- **Infrastructure teardown** – Safe nuke.yml with production safeguards

#### NIST 800-53 Controls Implemented
- **AC-2** – Account Management: SSH hardening, root lockout, fail2ban rate limiting
- **CM-7** – Least Functionality: Kernel module blacklisting (cramfs, freevxfs, jffs2, hfs, hfsplus, squashfs, udf)
- **SC-7** – Boundary Protection: UFW firewall + OCI iptables killswitch with deadman switch
- **SI-4** – System Monitoring: CrowdSec bot detection & real-time IP banning
- **AU-12** – Audit Generation: auditd system-call logging for privileged commands
- **SC-28** – Data at Rest: Vault encryption (disk encryption audit-only, not automated)

#### Critical Security Fixes (Blockers Resolved)
- **✅ Fixed Idempotence** – OCI killswitch tasks now report correct status on repeated runs
  - All `changed_when: true` statements replaced with conditional logic
  - Playbooks safe to run multiple times without false positives
  
- **✅ Privilege Isolation** – Portainer Edge Agent now runs as unprivileged user (65534:65534)
  - Mitigates privilege escalation via docker socket
  - Updated security documentation explaining limitations of `:ro` mount
  
- **✅ Deadman Switch Safety** – atd service validation before scheduling
  - Fails safely if at daemon not running  
  - Prevents race condition in OCI killswitch activation

#### Secondary Hardening Improvements
- **Resource Limits** – All containers (Caddy, Portainer) have CPU/memory limits defined
- **Pre-commit Hooks** – Local validation prevents credential commits & linting failures
  - detect-secrets baseline clean (zero credential exposure)
  - ansible-lint & yamllint automatic validation
  - gitleaks git security audit
  
- **GitHub Actions CI/CD** – Automated security-first pipeline
  - Multi-version Python testing (3.11, 3.12)
  - NIST control verification on every PR
  - Container security scanning
  - Dependency vulnerability detection
  
- **Linting Configuration** – Strict ansible-lint & yamllint rules
  - Min Ansible version 2.16 enforced
  - 120-char line limit, 2-space indentation
  - Security-focused rule customization

#### Documentation
- **CONTRIBUTING.md** – Updated with pre-commit setup & quality standards
- **RELEASE.md** – v1.0.0 release procedure & validation checklist
- **ARCHITECTURE.md** – Complete system design & NIST control mapping
- **README.md** – Clear, honest documentation (SC-28 marked as "audit-only")

#### Developer Experience
- **Pre-commit hook integration** – `pip install pre-commit && pre-commit install`
- **Local testing simplified** – Single command validates entire codebase
- **Idempotence verified** – Safe for repeated execution in production
- **Contributions welcomed** – Clear issue templates & contributor guidelines

#### Known Limitations
- **Disk Encryption (SC-28)** – Not automated; handled at provisioning layer
- **AuditD Performance** – Large audit logs may impact I/O on high-volume systems
- **CrowdSec Configuration** – Requires fine-tuning per environment (not universal)
- **OCI Killswitch** – Brief connectivity loss during iptables reset (by design, not a bug)

#### Testing & Quality Assurance
- ✅ All NIST control claims verified against actual code implementation
- ✅ Zero security findings from principal security auditor review
- ✅ Idempotence validated across multiple playbook runs
- ✅ Container security standards enforced (no-new-privileges, resource limits, unprivileged users)
- ✅ GitHub Actions CI/CD fully functional with security gates

---

## Future Roadmap

See [ROADMAP.md](ROADMAP.md) for v1.1.0+ planned features:
- Interactive setup wizard
- Additional NIST controls (AC-3, SC-28 automation)
- Enhanced monitoring dashboards
- Commercial monitoring platform
