# Changelog

## [5.0.6] - 2026-04-11

### Fixes

- **Tailscale ACL template rendering compatibility**: `roles/tailscale_client/templates/tailscale-acls.json.j2` no longer relies on the `convert_data` override, keeping ACL rendering compatible with current JSON parsing behavior.

## [5.0.5] - 2026-04-11

### Fixes

- **CrowdSec monitor reliability improvements**: `scripts/monitor-crowdsec.sh` now has stronger health checks and a Python fallback for JSON parsing.

## [5.0.4] - 2026-04-10

### Chore

- **Ingress ownership and CrowdSec log visibility hardening**: `roles/stack_ingress/tasks/main.yml` now enforces remapped ownership and ACL log access to keep Caddy logs readable to host-level CrowdSec.

## [5.0.3] - 2026-04-10

### Fixes

- **Network isolation hardening for optional stacks**: removed direct host port publishing for internal services in `recommended_apps/n8n/docker-compose.yml`, `roles/stack_portainer/templates/portainer-server.yml.j2`, and `roles/observability/templates/observability-stack-docker-compose.yml.j2` to reduce WAF bypass risk.

## [5.0.2] - 2026-04-04

### Refactor

- **Runtime normalization across Ansible roles and inventory model**: standardized task/module style, inventory/runtime config consistency, and role-level structure refinements across core security, observability, ingress, Portainer, Docker, and tailscale workflows.

### Chore

- **Recommended app artifacts normalized**: refreshed `recommended_apps/*` compose templates and `.env.example` consistency for Chatwoot, n8n, Twenty CRM, and Uptime Kuma.
- **Documentation/governance alignment update**: refreshed architecture, compliance, contributing, release, roadmap, and README references to match latest repository behavior.

## [5.0.1] - 2026-04-04

### Chore

- **Git ignore hardening for local JS package managers**: added `.pnpm/` and `node_modules/` to `.gitignore` to prevent local artifact leakage into commits.

## [5.0.0] - 2026-04-04

### Breaking Changes

- **Toolchain contract updated**: dependency and hook stack moved to the new baseline with updated Ansible ecosystem pins and pnpm-based Prettier execution policy.
- **Collection major upgrades**: updated `community.general` (`8.x` -> `12.x`) and `ansible.posix` (`1.x` -> `2.x`) along with related collection/runtime updates, requiring validation in existing operator environments.

### Tooling

- **pre-commit modernization**: updated hook sources/versions, moved shellcheck hook source, and switched markdown formatting to local pnpm execution.
- **Core Python deps refreshed**: updated `ansible-core`, `ansible-lint`, lockfile, and related project dependency metadata.

## [4.3.1] - 2026-04-04

### Fixes

- **Vault prompt ergonomics in Make deploy paths**: deploy-oriented Make targets now include Vault prompt behavior by default to avoid decrypt failures when encrypted runtime variables are present.

### Documentation

- **Commands runbook aligned to Make runtime behavior**: deployment examples and operator guidance were synchronized with current Make execution defaults.

## [4.3.0] - 2026-04-01

### Fixes

- **APT reliability hardening across roles**: Introduced shared `apt_refresh` flow in `roles/common/tasks/apt_refresh.yml` and reused it from `common`, `docker`, `security`, `crowdsec`, and `tailscale_client` roles to reduce lock contention and transient cache-refresh failures.
- **Package operation stability**: Added `lock_timeout: 600` to critical `ansible.builtin.apt` tasks affecting base packages, Docker engine installation, compliance tooling, CrowdSec, Tailscale, and NIST audit dependencies.
- **CrowdSec monitor robustness**: `scripts/monitor-crowdsec.sh` now checks for required tooling, degrades gracefully when `systemctl` is unavailable, removes `jq` dependency by parsing JSON with `uv run python`, and returns non-zero on warning/error states.
- **Bootstrap script safety**: `scripts/setup.sh` now standardizes execution through `uv`, validates repository prerequisites before running, tightens secret-file handling, and extends validation coverage (`monitoring.yml` + vault checks).

### Features

- **Make-based operations interface**: Added a project `Makefile` as the primary command surface for sync, lint, deploy, validation, vault operations, observability checks, and guarded destructive operations.

### Documentation

- **Documentation tree consolidation**: Project, compliance, architecture, and operations references are now organized under `docs/` with updated links from `README.md` and workflow comments.
- **Command source-of-truth policy**: `README.md` now defers command execution details to `docs/operations/COMMANDS.md` to reduce drift and keep operational runbooks centralized.

## [4.2.0] - 2026-03-30

### Security

- **System hardening enhancements**: Enhanced system security configurations and
  compliance settings across the suite to reinforce the hardening baseline.

### Features

- **App deployment configurations added**: Introduced secure configuration and
  deployment files (Docker Compose and `.env.example`) for Chatwoot, n8n,
  Twenty CRM, and Uptime Kuma to the recommended apps catalog.

### Fixes

- **Script execution permissions**: Corrected file permissions for
  `monitor-crowdsec.sh` and `setup.sh` to ensure proper execution during setup
  and monitoring.
- **Dependency pinning**: Pinned versions of dependencies to specific releases
  to ensure stable, reproducible builds and prevent upstream breakage.

### Documentation

- **Compliance guidance updated**: Updated compliance warnings across multiple
  roles to enhance overall security guidance and operator awareness regarding
  NIST standards.

## [4.1.1] - 2026-03-16

### Security

- **Tag-gated security audit workflow**: GitHub Actions `Security Audit` now
  runs only on version tags (`v*`) and manual dispatch, matching the release
  process and avoiding non-release noise.
- **Local/remote audit parity**: The release procedure now documents the exact
  local commands required before tagging so the same security gates are executed
  before remote publication.

### Fixes

- **detect-secrets baseline repaired**: Regenerated `.secrets.baseline` for
  `detect-secrets 1.5.0` compatibility, restoring baseline validation in local
  and CI audit flows.

### Tooling

- **Security workflow scope tightened**: `security-audit.yml` now focuses only
  on security controls relevant to release gating: secrets baseline validation,
  tracked-secrets guard, high-risk credential pattern scan, and dependency
  vulnerability audit via `pip-audit`.

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
