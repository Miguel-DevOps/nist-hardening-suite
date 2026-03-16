# Changelog

## [4.1.0] - 2026-03-15

### Features
- **Caddyfile integration mode examples**: `Caddyfile.example.j2` ships three
  annotated Uptime Kuma integration modes: VPN-only (Zero Trust recommended),
  global open (anti-pattern, explicitly labeled), and global with WAF
  (secure public exposure). WAF `SecRuleEngine` switched to `DetectionOnly`
  with structured audit logging in the example.

### Documentation
- **ROADMAP updated**: Added backlog item to rename `tailscale_subnet` to a
  VPN-agnostic overlay variable (e.g. `management_overlay_subnet`) for
  multi-VPN and Headscale compatibility.

## [4.0.0] - 2026-03-15

### Breaking Changes
- **Observability stack scope reduced**: `monitoring.yml` observability stack now
  deploys only VictoriaMetrics + Loki + Grafana. Uptime Kuma is no longer
  deployed by the `observability` role.
- **Operational transport policy hardened**: `stacks.yml`, `monitoring.yml`, and
  `nuke.yml` now require `ansible_host` to be inside `tailscale_subnet`
  (default `100.64.0.0/10`) before remote execution. Public-IP operations in
  these playbooks now fail at preflight; only `site.yml` retains bootstrap over
  public IP by design.

### Fixes
- **nuke.yml transport bug**: Removed the `pre_task` that silently overrode
  `ansible_host` with `public_ip` before teardown, causing nuke operations to
  attempt connection via public IPs and violating Zero Trust expectations.
- **nuke.yml clarity and safety copy**: Replaced legacy branding/messages with
  structured NIST-aligned header, risk notes, and role-aligned usage examples.

### Features
- **Recommended app catalog introduced**: added `recommended_apps/uptime-kuma/`
  with a secure, Caddy-oriented compose and `.env.example` for optional,
  plug-and-play deployment.
- **Overlay subnet as source of truth**: `tailscale_subnet` in
  `group_vars/all/main.yml` is now the canonical variable for management
  overlay validation checks across operational playbooks.

### Documentation
- Added `APP_RECOMMENDED_GUIDE.md` to define standards for optional applications
  (Caddy-first exposure, Zero Trust defaults, and Portainer-friendly operations).

## [3.1.0] - 2026-03-14

### Security
- **Ingress runtime hardening**: Caddy ingress compose now enforces
  `read_only: true` and a restricted `/tmp` tmpfs mount (`noexec,nosuid,nodev`)
  to reduce writable surface.
- **Runtime validation gates**: Ingress deployment now validates runtime
  container user and validates active Caddy config before final success output.

### Features
- **Operator-managed policy flow preserved**: WAF mode and per-application
  routing remain defined directly in `Caddyfile.j2`/`Caddyfile.example.j2` for
  explicit Zero Trust control.
- **Ansible-native ingress checks**: Replaced direct Docker CLI command tasks
  in ingress validation with `community.docker` modules where possible.
- **Exporter hardening profile updated**: Node Exporter and cAdvisor example
  stacks now run in bridge mode with read-only host mounts, removing
  `network_mode: host`/`pid: host` from exporter examples.
- **Observability template consolidation**: Exporters now use a single role
  template rendered for both brain and muscle nodes, and the observability
  stack compose is generated from dedicated role templates.

### Documentation
- **Observability security posture clarified**: README now states bridge-mode
  exporter policy and defers host-mode advanced metrics to a future,
  controlled exception path.

### Operational Model
- **Split preparation flow in monitoring playbook**: `monitoring.yml` now prepares exporter assets on all nodes with `enable_metrics_exporters: true` and prepares full stack assets only on brain nodes.
- **Observability deployment automated end-to-end**: Exporters and the brain observability stack are now deployed by Ansible with `community.docker.docker_compose_v2`.
- **Vault-backed runtime secrets**: Observability live `.env` is rendered from Ansible variables and secrets, replacing the prior manual Portainer-only environment entry flow.
- **Per-tool observability deploy tags**: `monitoring.yml` now supports targeted deployment tags for `node_exporter`, `cadvisor`, `victoriametrics`, `loki`, `grafana`, `uptime_kuma`, plus grouped tags for `exporters`, `stack`, and `observability_stack`.

### Cleanup
- **Removed unused env vars**: Dropped `WAF_ENABLED` and `ACME_AGREE` from ingress compose template because they were not consumed by the Caddy runtime in this stack.
- **Observability nuke cleanup hardened**: `nuke.yml` now always attempts to remove both observability networks to prevent stale network-name reuse across future redeployments; deletion remains non-fatal if a shared external network is still in use.
- **Per-tool observability cleanup tags**: `nuke.yml` now supports targeted cleanup tags for `node_exporter`, `cadvisor`, `victoriametrics`, `loki`, `grafana`, `uptime_kuma`, plus grouped tags for `exporters`, `observability_stack`, and `observability_networks`.

## [3.0.1] - 2026-03-13

### Fixes
- **Portainer Edge Agent**: Fixed template to use the resolved edge key variable (`portainer_edge_key_resolved`) instead of the removed legacy variable, preventing deployment failures when using the new key map.

All notable changes to NIST Hardening Suite are documented here.

## [3.0.0] - 2026-03-13

### Breaking Changes
- **Portainer Edge key input model changed**: Edge authentication now resolves from `portainer_edge_keys_by_node` keyed by exact inventory hostname.
  Single-value `portainer_edge_key` is no longer used in current role logic.

### Features
- **Brain-aware Edge association**: Added `portainer_edge_target_brain` routing with validation against inventory `groups['brain']`.
- **Edge Agent scope expansion**: Edge deployment flow now supports both `brain` and `muscle` groups where keys are present.

### Security
- **Portainer server hardening**: Removed direct Docker socket mount from the Portainer server service and removed `9000` publish in the server template, keeping the Edge tunnel path (`9443`/`8000`).
- **TLS identity alignment**: Portainer TLS certificate CN now follows `inventory_hostname` and SAN generation removes unrelated default DNS aliases.

### Documentation
- Updated release and roadmap references to align with the `v3.0.0` release tag and current Portainer Edge behavior.
- Updated contributing guidance and secrets examples for `portainer_edge_keys_by_node` usage.

## [2.0.0] - 2026-03-13

### Breaking Changes
- **Tailscale ACL automation is now OAuth-only**: `tailscale_acl_key` must be a `tskey-client-*` OAuth client secret and must be paired with `tailscale_acl_client_id`.
  Long-lived API access tokens are no longer accepted for ACL policy management.
- **Upgrade impact**: Existing deployments using legacy Tailscale ACL API tokens must migrate credentials before applying this release.

### Features
- **Tailscale ACL safety**: ACL policies are validated with `POST /api/v2/tailnet/{tailnet|\-}/acl/validate` before apply, reducing the risk of pushing malformed Zero Trust policy.
- **Caddy ingress bootstrap**: Added `roles/stack_ingress/templates/Caddyfile.example.j2` as a tracked baseline template for site-specific ingress customization.

### Fixes
- **Tailscale recovery**: The client role now clears stale `NeedsLogin` state before retrying authentication and emits redacted diagnostics on failure.
- **Tailscale daemon flags**: UDP port overrides are configured only when `tailscale_udp_port` is explicitly set; metrics port configuration no longer mutates the daemon listen port.
- **Ansible fact access**: Updated affected roles to use `ansible_facts[...]` consistently for better compatibility with current Ansible versions.
- **Ingress preflight**: `stack_ingress` now fails early with a clear message when `Caddyfile.j2` is missing.

### Documentation
- Updated release guidance to map SemVer decisions to Conventional Commit-style messages, including `!` for breaking changes.
- Updated setup docs and secrets examples for Tailscale OAuth credentials and local `Caddyfile.j2` workflow.

## [1.3.1] - 2026-03-12

### Bug Fixes - Caddy Security Integration Audit (NIST 800-53)

Resolves all findings from the internal security audit of Caddy's integration into the hardening suite.
No breaking changes; all fixes are backwards-compatible.

#### AC-2 - Account Management
- **Fixed:** Caddy container was running under UID 1000 (default system user), not a dedicated service account.
  The `stack_ingress` role now creates a `caddy` system user (`--system --no-create-home --shell /usr/sbin/nologin`)
  before provisioning directories, and overrides `caddy_user_uid`/`caddy_user_gid` facts from the actual system user
  via `ansible.builtin.getent` at runtime. The container's `user:` field is aligned to the host service account identity.
- **Fixed:** Added explicit host directories `/etc/caddy` and `/var/www/html` with ownership bound to `caddy`
  to satisfy least-privilege filesystem ownership checks in hardened environments.

#### AU-12 - Audit Generation
- **Fixed:** AuditD had no rules covering Caddy configuration or log files.
  Added `auditd` watch rules for `{{ app_base_dir }}/ingress/Caddyfile`, `{{ app_base_dir }}/ingress/`,
  and `/var/log/caddy` (keys: `caddy_config_change`, `caddy_stack_change`, `caddy_log_tampering`).
- **Fixed:** Caddyfile deployed with world-readable `mode: '0644'`; corrected to `'0640'`.

#### SI-4 - System Monitoring (CrowdSec)
- **Fixed:** `/var/log/caddy` was never created on the host, causing Caddy log monitoring to be skipped.
  The `stack_ingress` role now provisions `/var/log/caddy` owned by the `caddy` service user (`mode: '0750'`).
- **Fixed:** Caddy logs were routed only to Docker's `json-file` runtime; now also bind-mounted to
  `/var/log/caddy` on the host so CrowdSec, AuditD, and forensic reviews can access them directly.
- **Fixed:** CrowdSec log acquisition now includes explicit sources for both `syslog` and `caddy` log types.
- **Fixed:** Added `cscli collections install crowdsecurity/caddy` so CrowdSec can parse Caddy JSON logs.

#### SC-7 - Boundary Protection
- **Fixed:** Caddy admin API (`:2019`) was not explicitly restricted in global config.
  Added `admin localhost:2019` to confine it to loopback.

#### SC-28 / Configuration Hygiene
- **Fixed:** ACME `email` directive was hardcoded as `admin@example.com`.
  Replaced with `{{ caddy_acme_email | default('admin@example.com') }}` and documented
  `caddy_acme_email` in `group_vars/all/secrets.yml.example`.
- **Fixed:** Caddy global block now writes structured JSON logs to `/var/log/caddy/access.log`
  with rotation (`100mb`, 5 files, 720h retention).

#### Variables / Docs
- Updated `group_vars/all/images.yml` comments to clarify that `caddy_user_uid`/`caddy_user_gid`
  are fallback defaults overridden at runtime by `stack_ingress` (AC-2).
- Updated `group_vars/all/secrets.yml.example` with `caddy_acme_email` and updated UID/GID comments.

---


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
