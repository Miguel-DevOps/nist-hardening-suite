# Compliance Overview | NIST Hardening Suite

This document provides an executive, implementation-grounded compliance view for CISO, CTO, and SRE audiences.
All claims are aligned to what is currently implemented in repository playbooks, roles, inventory model, and quality gates.

---

## Scope and Assurance Model

### Technical scope validated in this repository
- Bootstrap and hardening orchestration through root playbooks: `site.yml`, `stacks.yml`, `monitoring.yml`, `nuke.yml`.
- Security controls implemented across roles: `security`, `crowdsec`, `tailscale_client`, `stack_portainer`, `observability`, `compliance`.
- Inventory and role model based on `brain` and `muscle` host groups.
- Global and per-group behavior configured in `group_vars/all`, `group_vars/brain`, and `group_vars/muscle`.
- Quality controls defined with `.ansible-lint`, `.yamllint`, and `.pre-commit-config.yaml`.

### Compliance assurance boundaries
- This repository provides technical implementation evidence and mappings, not a formal certification.
- Framework mappings must be validated against your legal, sector, and audit context.
- NIST SC-28 is partially implemented: secrets-at-rest encryption is automated with Ansible Vault; full disk encryption is audited but not provisioned by this suite.

---

## Executive Positioning by Framework

### NIST SP 800-207 (Zero Trust Architecture)
- Overlay-only transport is enforced in non-bootstrap playbooks (`stacks.yml`, `monitoring.yml`, `nuke.yml`) by asserting `ansible_host` belongs to the management subnet.
- Identity and policy-based segmentation are implemented via Tailscale tags and ACL automation.
- Portainer Edge Agent uses a pull model that avoids inbound management ports on managed nodes.

Reference:
- [NIST SP 800-207](https://csrc.nist.gov/pubs/sp/800/207/final)

### NIST SP 800-53 (Implemented Control Families)
- AC-2: SSH hardening, root login restrictions, brute-force mitigation.
- CM-7: module/filesystem reduction and sysctl security baseline.
- SC-7: host boundary controls and segmentation posture.
- SI-4: intrusion monitoring and detection via CrowdSec.
- AU-12: audit generation with auditd rules and evidence extraction.
- SC-28: encrypted secrets management; disk encryption verification only.

Reference:
- [NIST CSRC](https://csrc.nist.gov/)

### CIS Benchmarks Level 1 (Ubuntu/Debian, generic mapping)
- SSH baseline hardening aligns with CIS secure remote administration expectations.
- UFW default-deny posture aligns with host firewall baseline requirements.
- Kernel/filesystem and sysctl hardening align with least-functionality and network hardening practices.
- Audit and security telemetry align with logging and monitoring expectations.

Reference:
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks)

### ENS / EU Sovereignty / Cloud-Exit Context
- The same hardening baseline is portable across OCI and Hetzner bare metal.
- This portability supports cloud-exit strategy, data sovereignty posture, and reduced provider lock-in.
- Technical equivalences to ENS control intent are mapped in detail in companion documentation.

References:
- [ENS - CCN-CERT](https://www.ccn-cert.cni.es/)
- [ENS - BOE](https://www.boe.es/)

### DORA (Digital Operational Resilience Act)
- Continuous monitoring and incident visibility are supported through CrowdSec and the optional observability stack.
- Operational repeatability and traceability are supported through Ansible automation and linted infrastructure-as-code.

References:
- [DORA - EUR-Lex](https://eur-lex.europa.eu/homepage.html)
- [EIOPA](https://www.eiopa.europa.eu/)

### MITRE ATT&CK (Blue Team Defensive Mapping)
- Defensive tooling in this suite is mapped to high-probability attack paths such as brute force, exposed service exploitation, and lateral movement.
- Mapping detail and rationale are maintained in companion documentation.

Reference:
- [MITRE ATT&CK](https://attack.mitre.org/)

---

## Documentation Split (Authoritative Structure)

To keep this file executive and practical, detailed evidence is split into dedicated files:

- `COMPLIANCE_MAPPINGS.md`: Full matrices and implementation mapping.
- `REGULATORY_REFERENCES.md`: Official authority links and source control for citations.
- `AUDIT_EVIDENCE.md`: Operational evidence checklist and lint/playbook verification commands.

---

## Residual Risk Notes

- SC-28 full-disk encryption remains an external provisioning responsibility.
- A mapped control does not imply legal certification readiness without contextual validation and evidence collection.
- Regulatory mappings are technical and implementation-centric by design.

---

Maintained by the NIST Hardening Suite project.
