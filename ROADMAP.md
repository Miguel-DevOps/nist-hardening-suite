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

### What Is Working Well in `v1.2.0`
- NIST-focused architecture remains consistent (`AC-2`, `CM-7`, `SC-7`, `SI-4`, `AU-12`, `SC-28` audit scope).
- Security stack is cohesive: SSH hardening, UFW/fail2ban, CrowdSec, Tailscale, Vault workflow.
- Recent releases improved runtime compatibility, Portainer/Tailscale hardening, and observability reliability.
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
- `v1.2.1` - Operational hardening and documentation parity.

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
- `v1.3.0` - Compliance evidence and operability consistency.

## U2 - Strategic (60-120 days)

### U2.1 Additional Controls and Security Depth
- Expand practical enforcement around `AC-3`, `SI-3`, and `SC-28` optional automation paths.

### U2.2 Policy-as-Code Guardrails
- Introduce guardrails for module usage and documented exceptions.

### U2.3 Scale and Platform Readiness
- Improve multi-node resilience and integration templates.

### Planned Release Target
- `v1.4.0` - Policy and scale maturity.

## Future Implementations (Backlog)
- Interactive setup/diagnostics wizard.
- Compliance reporting outputs (JSON/HTML/PDF).
- Image provenance/signing pipeline.
- Managed monitoring operation packs.

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
Last updated: 2026-03-12