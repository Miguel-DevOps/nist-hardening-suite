# NIST Hardening Suite - Development Roadmap

## Vision
Consolidate the NIST Hardening Suite as a practical, transparent, and auditable security baseline for hybrid infrastructure, keeping a balance between operational simplicity and compliance rigor.

## Current Status (Verified from Git History)

### Released Versions
| Version | Date | Evidence from git | Main Focus |
|---|---|---|---|
| `v1.0.0` | 2026-02-12 | tag on `a4d63b9` | Initial production release and NIST baseline controls |
| `v1.1.0` | 2026-03-08 | tag on `a12e836` | Runtime compatibility and security hardening |
| `v1.2.0` | 2026-03-08 | tag on `2b621a1` | Portainer TLS hardening, Tailscale ACL improvements, observability fixes |
| `v1.3.0` | 2026-03-12 | tag on `21a5d19` | Security hardening fixes, Tailscale auth key hardening, Portainer Edge improvements, `uv` toolchain migration |
| `v1.3.1` | 2026-03-12 | tag on `c19f7c7` | Caddy security integration audit fixes across AC-2, AU-12, SI-4, SC-7, and configuration hygiene |
| `v2.0.0` | 2026-03-13 | tag on `6416f11` | Breaking release: Tailscale ACL OAuth-only credentials and release governance alignment |
| `v3.0.0` | 2026-03-13 | release tag on current `master` | Breaking release: Portainer Edge key-per-node migration, brain routing, and server hardening |
| `v3.0.1` | 2026-03-13 | tag on `d88d649` | Hotfix: Portainer Edge resolved key variable in agent template |
| `v3.1.0` | 2026-03-15 | (planned tag) | Observability template consolidation, Caddy WAF v2 pin, ingress runtime hardening, exporter bridge-mode hardening |
| `v4.0.0` | 2026-03-15 | (planned tag) | Breaking: Uptime Kuma decoupled from observability role; transport policy enforces overlay-only operations in non-bootstrap playbooks |
| `v4.1.0` | 2026-03-15 | (planned tag) | Caddyfile optional-app integration mode examples and roadmap alignment updates |
| `v4.1.1` | 2026-03-16 | (planned tag) | Patch: detect-secrets baseline repair and tag-driven security audit workflow parity |

### What Is Working Well in Current Working Tree (Post-`v3.0.1`)
- NIST-focused architecture remains consistent (`AC-2`, `CM-7`, `SC-7`, `SI-4`, `AU-12`, `SC-28` audit scope).
- Security stack is cohesive: SSH hardening, UFW/fail2ban, CrowdSec, Tailscale, Vault workflow.
- Operational playbooks (`stacks.yml`, `monitoring.yml`, `nuke.yml`) enforce Tailscale-only transport via `tailscale_subnet` source-of-truth variable.
- Observability deployment is fully automated end-to-end via Ansible and Vault-backed secrets; Uptime Kuma is decoupled as a recommended app.
- Caddy WAF v2 is pinned, runtime-hardened, and ships annotated integration mode examples for optional app exposure patterns.
- Recent releases improved runtime compatibility, Portainer/Tailscale hardening, observability reliability, Caddy security monitoring/auditability, ACL policy safety checks, and Zero Trust transport enforcement.
- Tooling modernization is in place with `uv` and Python `3.14`.

### Improvement Focus (Without Overstating Risk)
- Reduce imperative tasks (`shell`/`command`) where native Ansible modules can improve idempotence and auditability.
- Improve tag semantics in destructive workflows (`nuke.yml`) for safer operations.
- Keep documentation, CI evidence, and implemented behavior aligned release to release.

## Priority Plan by Urgency

## U0 - Critical (0-30 days)

### U0.1 Hardening and Operability Hotfixes
- Refactor highest-impact imperative tasks in `nuke.yml` and core security roles.
- Keep exceptions documented when commands are technically required.
- NIST: `CM-6`, `CM-7`, `SI-10`.
- OWASP: `A05`.

### U0.2 Safer Execution Contracts
- Replace custom `all` tag usage with explicit operational tags (`destroy`, `data`, `network`, `verify`).
- Align runbook examples with real task tags.
- NIST: `CM-3`, `SC-7`.
- OWASP: `A05`, `A09`.

### U0.3 Stable and Deterministic Quality Gates
- Standardize CI and local docs around `uv run` command paths.
- Keep lint configs compatible with current `ansible-lint`/`yamllint` behavior.
- NIST: `CA-7`, `AU-6`, `SI-4`.
- OWASP: `A08`, `A09`.

### Planned Release Target
- `v2.0.1` - Operational hardening and documentation parity.

## U1 - High (30-60 days)

### U1.1 Inventory-Agnostic Security Defaults
- Continue removing host-specific assumptions.
- Formalize least-privilege defaults for Docker/UFW/IPv6 paths.
- NIST: `AC-2`, `SC-7`, `CM-7`.
- OWASP: `A01`, `A05`.

### U1.2 Compliance Evidence as Release Artifact
- Publish machine-readable evidence of controls in CI.
- Maintain control-to-task traceability matrix.
- NIST: `CA-2`, `CA-7`, `AU-12`.
- OWASP: `A09`.

### U1.3 Documentation-to-Implementation Alignment
- Ensure observability and security claims match deployed behavior.
- NIST: `SI-4`, `AU-12`.
- OWASP: `A09`.

### Planned Release Target
- `v2.1.0` - Compliance evidence and operability consistency.

## U2 - Strategic (60-120 days)

### U2.1 Additional Controls and Security Depth
- Expand practical enforcement around `AC-3`, `SI-3`, and `SC-28` optional automation paths.

### U2.2 Policy-as-Code Guardrails
- Introduce guardrails for module usage and documented exceptions.

### U2.3 Scale and Platform Readiness
- Improve multi-node resilience and integration templates.

### Planned Release Target
- `v2.2.0` - Policy and scale maturity.

## Future Implementations (Backlog)
- Interactive setup/diagnostics wizard.
- Compliance reporting outputs (JSON/HTML/PDF).
- Image provenance/signing pipeline.
- Managed monitoring operation packs.
- [ ] Support for advanced host metrics (`network_mode: host`) with dedicated segmentation, compensating controls, and NIST/CIS exception documentation.
- [ ] Improve cAdvisor zero-trust coverage on hardened Docker hosts (`userns-remap`) with explicit metric-tier profiles (strict, balanced, full) and documented tradeoffs per profile.
- [ ] Add optional per-node cAdvisor enablement in inventory/group vars so hardened nodes can run Node Exporter only while keeping centralized scrape configuration clean.
- [ ] Rename `tailscale_subnet` to a VPN-agnostic overlay variable (e.g. `management_overlay_subnet`) to support non-Tailscale overlays (Headscale, WireGuard, etc.) without requiring changes across multiple playbooks. `tailscale_subnet` would remain as an alias for backwards compatibility. Relevant controls: NIST `CM-6`, `SC-7`.

## Success Criteria

### For U0
- `uv run ansible-lint site.yml stacks.yml monitoring.yml nuke.yml` runs with no critical regressions.
- `uv run yamllint -c .yamllint .` runs clean for targeted release scope.
- `uv run ansible-playbook --syntax-check site.yml stacks.yml monitoring.yml nuke.yml` passes.

### For U1/U2
- Each release includes updated control mapping and evidence artifacts.
- Documentation and code claims remain synchronized.

## Governance Notes
- Keep claims verifiable and evidence-based.
- Prefer declarative Ansible modules; document imperative exceptions.
- Preserve pragmatic tone: highlight strengths, track improvements transparently.

---

Maintained by Miguel Lozano - Site Reliability Engineer & FinOps Architect
Last updated: 2026-03-15