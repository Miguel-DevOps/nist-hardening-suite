# NIST Hardening Suite - Development Roadmap

## Vision

Consolidate the NIST Hardening Suite as a practical, transparent, and auditable security baseline for hybrid infrastructure, keeping a balance between operational simplicity and compliance rigor.

## Current Status (Verified from Git History)

### Released Versions

| Version  | Date       | Evidence from git              | Main Focus                                                                                                                            |
| -------- | ---------- | ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------- |
| `v1.0.0` | 2026-02-12 | tag on `a4d63b9`               | Initial production release and NIST baseline controls                                                                                 |
| `v1.1.0` | 2026-03-08 | tag on `a12e836`               | Runtime compatibility and security hardening                                                                                          |
| `v1.2.0` | 2026-03-08 | tag on `2b621a1`               | Portainer TLS hardening, Tailscale ACL improvements, observability fixes                                                              |
| `v1.3.0` | 2026-03-12 | tag on `21a5d19`               | Security hardening fixes, Tailscale auth key hardening, Portainer Edge improvements, `uv` toolchain migration                         |
| `v1.3.1` | 2026-03-12 | tag on `c19f7c7`               | Caddy security integration audit fixes across AC-2, AU-12, SI-4, SC-7, and configuration hygiene                                      |
| `v2.0.0` | 2026-03-13 | tag on `6416f11`               | Breaking release: Tailscale ACL OAuth-only credentials and release governance alignment                                               |
| `v3.0.0` | 2026-03-13 | tag on `098ea1e`               | Breaking release: Portainer Edge key-per-node migration, brain routing, and server hardening                                          |
| `v3.0.1` | 2026-03-13 | tag on `d88d649`               | Hotfix: Portainer Edge resolved key variable in agent template                                                                        |
| `v3.1.0` | 2026-03-15 | tag on `bf4915a`               | Observability template consolidation, Caddy WAF v2 pin, ingress runtime hardening, exporter bridge-mode hardening                     |
| `v4.0.0` | 2026-03-15 | tag on `0301cb8`               | Breaking: Uptime Kuma decoupled from observability role; transport policy enforces overlay-only operations in non-bootstrap playbooks |
| `v4.1.0` | 2026-03-15 | tag on `2e7fc8b`               | Caddyfile optional-app integration mode examples and roadmap alignment updates                                                        |
| `v4.1.1` | 2026-03-16 | tag on `12cec68`               | Patch: detect-secrets baseline repair and tag-driven security audit workflow parity                                                   |
| `v4.2.0` | 2026-03-30 | tag on `8bf5ea1`               | Feature: Added secure deployment configs for Chatwoot, n8n, Twenty CRM, and Uptime Kuma; enhanced hardening and pinned dependencies   |
| `v4.3.0` | 2026-04-01 | tag on `68bac30`               | Reliability hardening across roles, Make-based operations interface, CrowdSec monitor robustness, and bootstrap safety improvements   |
| `v4.3.1` | 2026-04-04 | tag on `7dc543f`               | Patch: Vault prompt ergonomics in Make deployment paths and runbook parity updates                                                    |
| `v5.0.0` | 2026-04-04 | tag on `398de28`               | Breaking: Toolchain contract update, major collection upgrades, and pnpm-based pre-commit formatting policy                           |
| `v5.0.1` | 2026-04-04 | tag on `8ae5996`               | Patch: Git ignore hardening for `.pnpm/` and `node_modules/`                                                                          |
| `v5.0.2` | 2026-04-04 | tag on `4f11446`               | Runtime normalization across Ansible roles/inventory, app compose normalization, and documentation governance refresh                 |
| `v5.0.3` | 2026-04-10 | tag on `0acfb55`               | Network isolation hardening for optional stacks                                                                                       |
| `v5.0.4` | 2026-04-10 | tag on `0acfb55`               | Ingress ownership and CrowdSec log visibility hardening                                                                               |
| `v5.0.5` | 2026-04-11 | tag on `293e0c9`               | CrowdSec monitor reliability improvements                                                                                             |
| `v5.0.6` | 2026-04-11 | tag on `ebc9a48` (current tag) | Tailscale ACL template rendering compatibility                                                                                        |

### What Is Working Well in Current Working Tree (v5.0.7-dev)

- NIST-focused architecture remains consistent (`AC-2`, `CM-7`, `SC-7`, `SI-4`, `AU-12`, `SC-28` audit scope).
- Security stack is cohesive: SSH hardening, UFW/fail2ban, CrowdSec, Tailscale, Vault workflow.
- Operational playbooks (`stacks.yml`, `monitoring.yml`, `nuke.yml`) enforce Tailscale-only transport via `tailscale_subnet` source-of-truth variable.
- Observability deployment is fully automated end-to-end via Ansible and Vault-backed secrets.
- Recommended app catalog now provides secure, Zero Trust-aligned deployment configurations for Chatwoot, Metabase, n8n, Twenty CRM, and Uptime Kuma.
- **Caddy Node Isolation (NEW v5.0.7)**: Per-node Caddyfile routing via `target_group ∩ group_names` - management routes isolated to brain, app routes to muscle. Three-layer variable model: vault (domains, certs), inventory inline vars (caddy_node_id, caddy_coraza_mode per host), group_vars (caddy_type, caddy_admin_enabled defaults). Per-node Coraza WAF mode - brain-1 can be On while brain-2 is DetectionOnly simultaneously. TLS Origin Pull client authentication. Global security headers and HTTP→HTTPS redirect. Cloudflare origin certificates deployed only to target nodes. All domain data lives exclusively in the encrypted vault.
- Caddy WAF v2 is pinned, runtime-hardened, and ships annotated integration mode examples for optional app exposure patterns.
- System security configurations and compliance guidance are reinforced across multiple roles, with strict dependency pinning ensuring reproducible builds.
- Tooling modernization is in place with `uv` and Python `3.14`, including refreshed core pins (`ansible-core 2.20.4`, `ansible-lint 26.4.0`, `yamllint 1.38.0`) and pnpm-based markdown formatting policy in hooks.

### Improvement Focus (Without Overstating Risk)

- Reduce imperative tasks (`shell`/`command`) where native Ansible modules can improve idempotence and auditability.
- Improve tag semantics in destructive workflows (`nuke.yml`) for safer operations.
- Keep documentation, CI evidence, and implemented behavior aligned release to release.
- Maintain security parity and update cadence for the newly expanded recommended apps catalog.
- Remove remaining wrapper/mirror dependencies from developer tooling where official upstream OSS alternatives exist.

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

- `v5.0.7` - Operational hardening and documentation parity follow-up.

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

- `v5.1.0` - Compliance evidence and operability consistency.

## U2 - Strategic (60-120 days)

### U2.1 Additional Controls and Security Depth

- Expand practical enforcement around `AC-3`, `SI-3`, and `SC-28` optional automation paths.

### U2.2 Policy-as-Code Guardrails

- Introduce guardrails for module usage and documented exceptions.

### U2.3 Scale and Platform Readiness

- Improve multi-node resilience and integration templates.

### Planned Release Target

- `v6.0.0` - Policy and scale maturity.

## Future Implementations (Backlog)

- Interactive setup/diagnostics wizard.
- Compliance reporting outputs (JSON/HTML/PDF).
- Image provenance/signing pipeline.
- Managed monitoring operation packs.
- Current approved transitional exception: `ansible-vault` PyPI wrapper remains enabled for operational continuity of current key workflows until migration is complete.
- [ ] Toolchain migration policy: prefer official upstream projects with OSI-approved licenses only (MIT/Apache/GPL/BSD) and avoid BSL/non-open-core runtime dependencies in control-plane tooling.
- [ ] Replace wrapper hook `shellcheck-py/shellcheck-py` (MIT wrapper) with official `koalaman/shellcheck` binary workflow (GPL-3.0) managed in reproducible CI/WSL bootstrap.
- [ ] Replace `pre-commit/mirrors-prettier` (archived mirror) with official Prettier distribution from `prettier/prettier` (MIT) via pinned `pnpm` execution in hooks (policy: no npm).
- [ ] Migrate secrets lifecycle from transitional `ansible-vault` wrapper to official and auditable key-management baseline (Ansible-native vault workflows and/or Mozilla SOPS + age/GPG), including key custody, rotation, and recovery controls.
- [ ] Support for advanced host metrics (`network_mode: host`) with dedicated segmentation, compensating controls, and NIST/CIS exception documentation.
- [ ] Improve cAdvisor zero-trust coverage on hardened Docker hosts (`userns-remap`) with explicit metric-tier profiles (strict, balanced, full) and documented tradeoffs per profile.
- [ ] Add optional per-node cAdvisor enablement in inventory/group vars so hardened nodes can run Node Exporter only while keeping centralized scrape configuration clean.
- [ ] Rename `tailscale_subnet` to a VPN-agnostic overlay variable (e.g. `management_overlay_subnet`) to support non-Tailscale overlays (Headscale, WireGuard, etc.) without requiring changes across multiple playbooks. `tailscale_subnet` would remain as an alias for backwards compatibility. Relevant controls: NIST `CM-6`, `SC-7`.
- [ ] **Coraza full activation checklist** (follow-up to v5.0.7 F4): After OWASP CRS tuning period on muscle nodes (DetectionOnly), documented activation procedure with per-service WAF bypass audit, false-positive triage runbook, and gradual rollout plan (muscle-1 → muscle-2 → all workers).
- [ ] **Dynamic inventory migration** (follow-up to v5.0.7 inventory inline vars): If Terraform, AWX, or an OCI dynamic inventory plugin is adopted, the per-host `caddy_node_id` and `caddy_coraza_mode` inline vars in `hosts.ini` must be migrated to the new inventory system. The three-layer variable model (vault/inventory/group_vars) must be preserved regardless of the inventory backend. Flag this when the project adopts IaC-driven inventory.
- [ ] **Cloudflare Origin CA cert expiry monitoring** (follow-up to v5.0.7 F5): The `cloudflare-origin-pull-ca.pem` CA bundle has a finite validity period. Action items: (1) Check current expiry: `openssl x509 -in roles/stack_ingress/files/cloudflare-origin-pull-ca.pem -noout -enddate`. (2) Add Ansible preflight task: assert cert is not expired and warns at 30-day threshold using `openssl x509 -checkend 2592000`. (3) Document rotation process: download updated CA from Cloudflare's published URL, replace file, re-deploy via `stacks.yml --tags cloudflare,sc-8`, validate with `curl --cacert cloudflare-origin-pull-ca.pem` against a CF-origin service. CA cert expiry should block deploy if expired and log a warning if within the 30-day window.
- [ ] **Caddy node stack tests** (follow-up to v5.0.7): Add Molecule or integration tests validating per-node Caddyfile rendering (brain receives management routes, muscle receives app routes, certs isolated), preflight assertion coverage for `target_group`/`coraza_mode`/`admin_enabled`, and TLS Origin Pull verification.

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

Maintained by Miguel Lozano - Cloud Infrastructure Engineer & FinOps Specialist
Last updated: 2026-05-05
