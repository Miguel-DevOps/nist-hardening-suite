# Compliance Mappings | NIST Hardening Suite

This document contains detailed, implementation-grounded mappings between repository controls and major compliance frameworks.
It is intended for technical auditors, security architects, and platform engineering teams.

---

## 1. Mapping Method

### Evidence sources used

- Root playbooks: `site.yml`, `stacks.yml`, `monitoring.yml`, `nuke.yml`.
- Role implementations: `roles/security`, `roles/crowdsec`, `roles/tailscale_client`, `roles/stack_portainer`, `roles/observability`, `roles/compliance`.
- Variables and topology model: `inventory/hosts.ini*`, `group_vars/all`, `group_vars/brain`, `group_vars/muscle`.
- Quality gates: `.ansible-lint`, `.yamllint`, `.pre-commit-config.yaml`.

### Coverage scale

- Implemented: control behavior is explicitly present in repository logic.
- Partial: control intent is supported but implementation depends on external layers.
- Contextual: mapping is functionally valid but must be adapted for formal audit scope.

---

## 2. NIST SP 800-53 Mapping (Current Repository Scope)

Reference:

- [NIST CSRC](https://csrc.nist.gov/)

| NIST Control                            | Intent                              | Repository Implementation                                                                        | Coverage    | Notes                                                                  |
| --------------------------------------- | ----------------------------------- | ------------------------------------------------------------------------------------------------ | ----------- | ---------------------------------------------------------------------- |
| AC-2 Account Management                 | Restrict and control account access | SSH hardening (`PasswordAuthentication no`, restricted root login), fail2ban SSH protections     | Implemented | Access hardening is host-based and automated in `roles/security`       |
| CM-7 Least Functionality                | Reduce unnecessary functionality    | Filesystem/module blacklisting and security sysctl baseline in `roles/security/tasks/nist.yml`   | Implemented | Includes module classification and enforcement when loadable           |
| SC-7 Boundary Protection                | Protect system boundaries           | UFW default-deny posture, ingress hardening, overlay-only assertions in non-bootstrap playbooks  | Implemented | Overlay transport checks in `stacks.yml`, `monitoring.yml`, `nuke.yml` |
| SI-4 System Monitoring                  | Monitor and detect security events  | CrowdSec agent + firewall bouncer + log acquisition (`auth.log`, `syslog`, Caddy logs)           | Implemented | Supports local mode and optional hybrid signal sharing                 |
| AU-12 Audit Generation                  | Produce auditable records           | auditd rules for privileged commands and security-critical paths, compliance evidence extraction | Implemented | Additional Caddy-related audit evidence captured in `roles/compliance` |
| SC-28 Protection of Information at Rest | Protect data at rest                | Secrets encryption via Ansible Vault + disk encryption status audit (LUKS check)                 | Partial     | Full disk encryption provisioning is out of scope for this repository  |

---

## 3. NIST SP 800-207 Zero Trust Mapping

Reference:

- [NIST SP 800-207](https://csrc.nist.gov/pubs/sp/800/207/final)

| Zero Trust Principle                 | Implementation Pattern                             | Evidence in Repository                                      |
| ------------------------------------ | -------------------------------------------------- | ----------------------------------------------------------- |
| Assume breach                        | Default-deny boundaries + continuous telemetry     | UFW + CrowdSec + auditd                                     |
| Explicit verification                | Policy checks before privileged network operations | Overlay-subnet assertions before stack/monitoring/nuke runs |
| Least privilege access               | Identity/tag-based remote management controls      | Tailscale ACL model (`brain` and `muscle` tags)             |
| Minimized exposed surfaces           | Pull-based management plane model                  | Portainer Edge Agent pull architecture                      |
| Continuous monitoring and adaptation | Persistent logging and incident telemetry          | CrowdSec collections + optional observability stack         |

---

## 4. CIS Benchmark Level 1 (Ubuntu/Debian Generic) Mapping

Reference:

- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks)

| CIS Domain (Generic L1)     | Repository Control Implementation                                       | Coverage    |
| --------------------------- | ----------------------------------------------------------------------- | ----------- |
| Secure SSH configuration    | SSH key-only posture, restricted root login, empty password disablement | Implemented |
| Host firewall baseline      | UFW deployment and enforcement                                          | Implemented |
| Brute-force mitigation      | fail2ban SSH jail with controlled thresholds and ignore list            | Implemented |
| Kernel/filesystem hardening | Blacklist of unused filesystems and modules                             | Implemented |
| Network hardening sysctl    | Redirect/source-route/rp_filter/syncookies/ASLR parameters              | Implemented |
| Logging and auditing        | auditd installation, rules, and evidence collection                     | Implemented |

Note: This matrix is intentionally generic and must be cross-checked against benchmark IDs for your exact OS release and profile.

---

## 5. ENS Functional Equivalence Mapping (Technical)

References:

- [ENS - CCN-CERT](https://www.ccn-cert.cni.es/)
- [ENS - BOE](https://www.boe.es/)

| NIST Anchor | ENS Functional Objective                | Repository Implementation                                                | Coverage   |
| ----------- | --------------------------------------- | ------------------------------------------------------------------------ | ---------- |
| AC-2        | Logical access control                  | SSH hardening, fail2ban, policy-governed access through overlay controls | Contextual |
| SC-7        | Communications and perimeter protection | UFW boundary policy, overlay-only control-path assertions                | Contextual |
| AU-12       | Activity logging and traceability       | auditd rules and evidence exports                                        | Contextual |
| SI-4        | Security monitoring and detection       | CrowdSec detection pipeline + optional observability telemetry           | Contextual |

Note: ENS alignment here is technical-functional and must be validated against system category and applicable ENS requirements in your governance context.

---

## 6. DORA Operational Resilience Contribution

References:

- [DORA - EUR-Lex](https://eur-lex.europa.eu/homepage.html)
- [EIOPA](https://www.eiopa.europa.eu/)

| DORA-Oriented Capability                 | Repository Support                                               | Coverage                     |
| ---------------------------------------- | ---------------------------------------------------------------- | ---------------------------- |
| Continuous operational monitoring        | Optional VictoriaMetrics/Loki/Grafana deployment and exporters   | Implemented (optional stack) |
| Incident visibility and response support | CrowdSec detection and local blocking workflows                  | Implemented                  |
| Controlled and repeatable change         | Ansible playbooks + lint/pre-commit quality controls             | Implemented                  |
| Management surface reduction             | Pull-based Portainer Edge model and overlay transport guardrails | Implemented                  |

---

## 7. MITRE ATT&CK Defensive Mapping

Reference:

- [MITRE ATT&CK](https://attack.mitre.org/)

| Repository Defensive Control           | ATT&CK Tactic                   | ATT&CK Technique Example                                    | Defensive Value                                     |
| -------------------------------------- | ------------------------------- | ----------------------------------------------------------- | --------------------------------------------------- |
| fail2ban + CrowdSec                    | Credential Access               | T1110 Brute Force                                           | Detects and blocks repeated authentication attempts |
| UFW default-deny posture               | Initial Access                  | T1190 Exploit Public-Facing Application                     | Reduces publicly exploitable service surface        |
| Tailscale ACL and overlay control path | Lateral Movement                | T1021 Remote Services                                       | Restricts unauthorized remote service traversal     |
| auditd privileged command tracking     | Detection and Forensics support | T1059 Command and Scripting Interpreter (detection context) | Increases traceability for investigation            |

---

## 8. Known Gaps and External Dependencies

- Full disk encryption provisioning is external to this repository.
- Regulatory alignment does not replace formal legal/audit interpretation.
- CIS benchmark item-level IDs are not enumerated in this repository and should be mapped per OS release during audit preparation.

---

Maintained by the NIST Hardening Suite project.
