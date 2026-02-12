# NIST Hardening Suite | Developmi

![Tool](https://img.shields.io/badge/Tool-Ansible_Core-red?style=for-the-badge)
![Standard](https://img.shields.io/badge/Standard-NIST_800--53-blue?style=for-the-badge)
![Encryption](https://img.shields.io/badge/Secrets-Ansible_Vault-yellow?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Production_Active-green?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)
![Maintainer](https://img.shields.io/badge/SRE_&_FinOps_Architect-Miguel_Lozano-black?style=for-the-badge)
![Hetzner](https://img.shields.io/badge/Provider-Hetzner_Bare_Metal-cc342d?style=for-the-badge&logo=data:image/svg%2bxml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMDAgMTAwIj48dGV4dCB4PSI1MCIgeT0iNjAiIGZvbnQtc2l6ZT0iNjAiIGZvbnQtd2VpZ2h0PSJib2xkIiBmaWxsPSJ3aGl0ZSIgdGV4dC1hbmNob3I9Im1pZGRsZSI+SDwvdGV4dD48L3N2Zz4=)
![OCI](https://img.shields.io/badge/Provider-Oracle_Cloud-f80000?style=for-the-badge&logo=data:image/svg%2bxml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMDAgMTAwIj48dGV4dCB4PSI1MCIgeT0iNjAiIGZvbnQtc2l6ZT0iNjAiIGZvbnQtd2VpZ2h0PSJib2xkIiBmaWxsPSJ3aGl0ZSIgdGV4dC1hbmNob3I9Im1pZGRsZSI+T0M8L3RleHQ+PC9zdmc+)

> 🛡️ **NIST‑ALIGNED HARDENING SUITE**
> 
> **The Script is Free. Peace of Mind Isn't.**
> 
> This open-source Ansible suite demonstrates enterprise‑grade security hardening aligned with NIST 800‑53.
> It implements NIST 800‑53 controls for hybrid cloud infrastructure:
> - SSH hardening & root account lockout (AC‑2)
> - Firewall enforcement with UFW (SC‑7) 
> - Intrusion prevention with CrowdSec (SI‑4)
> - Encrypted secrets management with Ansible Vault
> 
> **Business Model:** The hardening script is free (MIT licensed). I charge a monthly retainer for continuous monitoring via CrowdSec, ensuring your infrastructure stays compliant.

---

## 📖 Overview

The **NIST-Compliant Hardening Suite** is an automated configuration management framework designed to solve the **Security Parity** problem in hybrid cloud environments.

### 🎯 Initially Focused On:
- **🏢 Hetzner** – Bare Metal servers (Cloud specials, dedicated hosting)
- **☁️ Oracle Cloud** – OCI Compute instances (E2, Standard, Optimized shapes)

It guarantees that nodes running in **Oracle Cloud** and **Hetzner** maintain an identical defensive posture—independent of hardware architecture, hypervisor, or provider defaults.

> **Note:** While built for OCI + Hetzner, the playbooks are cloud-agnostic and should work on any Debian/Ubuntu-based system.

---

## 🚀 Quick Start

### Prerequisites
- Ansible Core 2.16+
- Python 3.12+
- `ansible-vault` for secret management  
- SSH access to target servers

### 1. Clone & Setup
```bash
git clone https://github.com/Miguel-DevOps/nist-hardening-suite.git
cd nist-hardening-suite

# Install Ansible collections
ansible-galaxy collection install -r requirements.yml
```

### 2. Configure Inventory
Edit `inventory/hosts.ini` with your server IPs and credentials:
```ini
[brain]
brain-hetzner ansible_host=YOUR_PUBLIC_IP ansible_user=root public_ip=YOUR_PUBLIC_IP

[muscle]  
muscle-oci-1 ansible_host=YOUR_PUBLIC_IP ansible_user=ubuntu public_ip=YOUR_PUBLIC_IP
```

### 3. Set Up Encrypted Secrets
```bash
# Copy and encrypt secrets (GitHub token + Tailscale key required)
cp group_vars/all/secrets.yml.example group_vars/all/secrets.yml
ansible-vault encrypt group_vars/all/secrets.yml

# Edit encrypted file
ansible-vault edit group_vars/all/secrets.yml
```

### 4. Run Base Hardening (NIST Compliance)
```bash
# Full NIST hardening (takes ~10-15 minutes)
ansible-playbook -i inventory/hosts.ini site.yml --ask-vault-pass

# Expected output includes:
# ✅ SSH password auth DISABLED (keys only)
# ✅ Fail2ban active (3 attempts = 1h ban)  
# ✅ UFW enabled with Docker ports configured
# ✅ Tailscale VPN mesh established
# ✅ NIST controls AC‑2, CM‑7, SC‑7, SI‑4, AU‑12, SC‑28 (secrets via Vault; disk encryption at provisioning) applied
```

### 5. Deploy Management Stack
```bash
# After hardening, deploy Portainer Edge Agent + Caddy
ansible-playbook -i inventory/hosts.ini stacks.yml --ask-vault-pass
```

### 5.1 Optional Add-on: Observability Stack (Anti-Bloat)
Use this only on servers with sufficient resources.
```bash
# Deploy VictoriaMetrics + Grafana + Loki + Uptime Kuma (optional)
ansible-playbook -i inventory/hosts.ini monitoring.yml --ask-vault-pass
```

### 6. Verify & Monitor
```bash
# Check security status
ansible all -i inventory/hosts.ini -m shell -a "tailscale status"

# View CrowdSec alerts (intrusion detection)
ansible all -i inventory/hosts.ini -m shell -a "cscli alerts list"

# Monitor audit logs (NIST AU‑12)
ansible all -i inventory/hosts.ini -m shell -a "tail -f /var/log/audit/audit.log"
```

### 📋 What Gets Installed
| Component | Purpose | NIST Control |
|-----------|---------|--------------|
| **UFW Firewall** | Default‑deny firewall with SSH rate limiting | SC‑7 |
| **Fail2ban** | Brute‑force protection (3 attempts = 1h ban) | AC‑2 |
| **Tailscale VPN** | Zero‑trust mesh network (replaces public SSH) | SC‑7 |
| **CrowdSec** | Collaborative intrusion prevention system | SI‑4 |
| **AuditD** | System call monitoring & audit trail | AU‑12 |
| **Docker Engine** | Container runtime (pinned versions) | CM‑7 |
| **Portainer Edge Agent** | Pull‑based container management (zero open ports) | SC‑7 |
| **Ansible Vault** | Encrypted secrets management | SC‑28 (Audit Only / Partial) |
 
**Note on SC‑28 (Data at Rest):** Implemented via Ansible Vault for secrets. Disk encryption must be handled at the provisioning layer (Tofu/Terraform). This suite does NOT encrypt disks and only audits for existing LUKS.

---
## ⚠️ Security Considerations

### 🛡️ Portainer Edge Agent (Only Mode)
The suite deploys **Portainer Edge Agent** only, which uses a **pull‑based architecture** with **zero open ports** on managed nodes. This eliminates lateral movement risks:

- **Zero open ports**: Edge Agents poll the Portainer server every 5 seconds via outbound connections
- **Reduced attack surface**: No API endpoints exposed on the Tailscale network  
- **True Zero Trust**: Agents initiate connections; they don't listen for incoming requests
- **Docker socket**: Mounted read‑only (`:ro`) to prevent container creation/removal

### 🔐 Tailscale ACLs (Zero Trust Networking)
**Required for production deployments**:
- ACLs enforce least‑privilege access between `brain` and `muscle` nodes
- Port‑level restrictions (e.g., SSH port 22)
- Tag‑based policies for simplified management
- Automated ACL configuration available via `tailscale_acl_key`

### ☢️ Nuclear Cleanup (`nuke.yml`)
This playbook is destructive and irreversible. It includes a mandatory confirmation prompt requiring the exact phrase `DESTROY_ALL_INFRASTRUCTURE`.
Safety valve: nuke is blocked on hosts in the `production` inventory group.

### ✅ Accepted Risks

- **SC‑28 (Data at Rest)**: Implemented via Ansible Vault for secrets. Disk encryption must be handled at the provisioning layer (Tofu/Terraform). This suite does NOT encrypt disks and only audits for existing LUKS. *Future releases may include automated LUKS provisioning as an optional feature.*
- **Docker Socket Access (Portainer Edge Agent)**: Risk Acceptance. The Portainer Edge Agent requires Docker socket access. This is mitigated by the pull-based architecture and Tailscale isolation, but represents a residual risk of privilege escalation if the container is compromised. Even with a read-only mount, the Docker socket provides root-level access to the host. *Future release: Docker Socket Proxy (Tecnativa) to restrict API calls.*
- **OCI Killswitch**: The aggressive iptables flushing may cause temporary loss of SSH access if UFW fails to start. Backup rules are stored in `/etc/iptables/rules.v{4,6}.backup` for manual recovery.

## 🎯 Execution Control & Tags

Run specific components using Ansible tags:

### Infrastructure Phases
```bash
# Phase 1: Base system only
ansible-playbook -i inventory/hosts.ini site.yml --tags base,system

# Phase 2: Security hardening only  
ansible-playbook -i inventory/hosts.ini site.yml --tags security,firewall

# Phase 3: Intrusion prevention (CrowdSec)
ansible-playbook -i inventory/hosts.ini site.yml --tags crowdsec,ips

# Phase 4: VPN mesh network
ansible-playbook -i inventory/hosts.ini site.yml --tags vpn,tailscale

# Phase 5: Docker engine
ansible-playbook -i inventory/hosts.ini site.yml --tags docker,containers
```

### NIST Control Groups
```bash
# Run specific NIST controls
ansible-playbook -i inventory/hosts.ini site.yml --tags nist          # All NIST controls
ansible-playbook -i inventory/hosts.ini site.yml --tags nist,ac-2     # Account management
ansible-playbook -i inventory/hosts.ini site.yml --tags nist,cm-7     # Least functionality
ansible-playbook -i inventory/hosts.ini site.yml --tags nist,sc-7     # Boundary protection
ansible-playbook -i inventory/hosts.ini site.yml --tags nist,si-4,au-12 # Monitoring & audit
ansible-playbook -i inventory/hosts.ini site.yml --tags nist,sc-28    # Data at rest
```

### Application Stacks
```bash
# Deploy specific stacks
ansible-playbook -i inventory/hosts.ini stacks.yml --tags ingress,caddy
ansible-playbook -i inventory/hosts.ini stacks.yml --tags portainer,management

# Optional observability add-on
ansible-playbook -i inventory/hosts.ini monitoring.yml --tags observability,monitoring
```

### Compliance Audit
```bash
# Run Lynis compliance audit (optional)
ansible-playbook -i inventory/hosts.ini site.yml --tags compliance
```

### Skip Components
```bash
# Skip VPN setup (use existing)
ansible-playbook -i inventory/hosts.ini site.yml --skip-tags tailscale,vpn

# Skip security tools (testing only)
ansible-playbook -i inventory/hosts.ini site.yml --skip-tags security,firewall,fail2ban
```

---

## 💼 Business Model: NIST‑Aligned Hardening & Monitoring

### Open Source Code, Commercial Monitoring
This project follows the **"Open Core"** business model:

| Offering | Description | Price |
|----------|-------------|-------|
| **Hardening Suite** | Complete Ansible codebase (MIT licensed) | **FREE** |
| **CrowdSec Monitoring** | Continuous intrusion detection & alerting | Monthly retainer |
| **Compliance Auditing** | Monthly NIST control validation reports | Included in retainer |
| **Emergency Response** | 24/7 security incident response | SLA‑based |

### Why This Model Works
1. **Transparency Builds Trust** – The hardening script is publicly auditable
2. **Security is Continuous** – Hardening is a one‑time action; threats evolve daily  
3. **Alignment of Incentives** – I profit only when your infrastructure stays secure
4. **Enterprise‑Grade at Startup Cost** – NIST compliance without Fortune‑500 budgets

### Get Started
1. **Use the free script** to harden your infrastructure
2. **Contact me** for a CrowdSec monitoring retainer
3. **Sleep better** knowing your compliance is actively monitored

---

## ❗ The Problem

Hybrid infrastructure introduces systemic security risks:

- **Default Insecurity**  
  Fresh Debian/Ubuntu installations prioritize usability over security.
- **Configuration Drift**  
  Manual hardening inevitably diverges between environments.
- **Secret Sprawl**  
  Plaintext credentials committed to Git represent a critical breach vector.

---

## ✅ The Solution

An **idempotent, auditable Ansible framework** that:

1. **Hardens** systems using CIS Benchmark Level 1–aligned controls  
2. **Defends** nodes via **CrowdSec** collaborative intrusion prevention  
 3. **Encrypts** all secrets using **Ansible Vault** in a GitOps workflow

---

## 🛡️ Architecture & Compliance Model

The suite converts a *vanilla* operating system into a *hardened bastion host*.

```mermaid
graph TD
    Ansible[Ansible Control Node] -->|SSH + Ansible Vault| OCI[OCI Production Node]
    Ansible -->|SSH + Ansible Vault| Hetzner[Hetzner Management Node]

    subgraph "Applied NIST Controls"
        OCI --> SSH["SSH Hardening (AC‑2)"]
        OCI --> FW["Firewall (SC‑7)"]
        OCI --> CM7["Least Functionality (CM‑7)"]
        OCI --> SI4["System Monitoring (SI‑4)"]
        OCI --> AU12["Audit Generation (AU‑12)"]
        OCI --> SC28["Data at Rest (SC‑28)"]
    end


```

## 📜 NIST 800-53 Control Mapping

| Control ID | Family              | Implementation                                                                 |
| ---------- | ------------------- | ------------------------------------------------------------------------------ |
| **AC-2**   | Account Management  | Root login disabled, SSH key‑only access, password authentication disabled     |
| **CM-7**   | Least Functionality | Unused kernel modules blacklisted, unnecessary filesystems disabled            |
| **SC-7**   | Boundary Protection | UFW firewall with default deny, provider‑specific iptables hardening           |
| **SI-4**   | System Monitoring   | AuditD system‑call monitoring + CrowdSec IPS (real‑time threat detection)      |
| **AU-12**  | Audit Generation    | Comprehensive audit trail for privileged commands & file access                |
| **SC‑28**  | Data at Rest        | Secrets via Ansible Vault; disk encryption handled at provisioning (audit only) |

---

## 🛠️ Engineering Roadmap

### Phase 1 — Base Hardening ✅

* [x] Hardened `sshd_config` template
* [x] UFW firewall with default deny
* [x] Automated security updates on bootstrap

### Phase 2 — System Monitoring (auditd) ✅

* [x] `auditd` installation & configuration
* [x] NIST‑aligned audit rules (SI‑4, AU‑12)
* [x] Real‑time syscall monitoring

### Phase 3 — Secrets Management (Ansible Vault) ✅

* [x] Centralized secrets with `ansible‑vault`
* [x] Encrypted variable validation
* [x] GitOps‑ready secret workflow

### Phase 4 — Least Functionality (CM‑7) ✅

* [x] Unused filesystems blacklisted
* [x] Kernel module hardening

### Phase 5 — Provider‑Agnostic Hardening ✅

* [x] Cloud provider detection (`hetzner`/`oci`)
* [x] OCI iptables killswitch
* [x] Hetzner rate‑limited SSH
* [x] CI/CD with convergence testing

---

## 💻 Code Highlights

### Secure Secret Loading (Ansible Vault)

Secrets are encrypted with `ansible-vault` and decrypted **in-memory only**, never passed as CLI arguments.

```yaml
# Encrypt secrets:
#   ansible-vault encrypt group_vars/all/secrets.yml

# Use in playbooks with --ask-vault-pass
- name: Load encrypted secrets
  include_vars:
    file: "group_vars/all/secrets.yml"
    name: vault
```

### System Monitoring — AuditD Rules (SI‑4 / AU‑12)

Compliance‑ready audit trail for privileged commands and sensitive files.

```yaml
- name: Configure auditd rules for privileged commands
  ansible.builtin.copy:
    dest: /etc/audit/rules.d/nist-hardening.rules
    content: |
      -a always,exit -F arch=b64 -S execve -k privileged_commands
      -w /etc/passwd -p wa -k identity_management
      -w /etc/shadow -p wa -k identity_management
```

### Least Functionality — Kernel Hardening (CM‑7)

Unused filesystems are disabled to prevent malicious mounts.

```yaml
- name: CM-7 | Blacklist unused filesystem kernel modules
  community.general.modprobe:
    name: "{{ item }}"
    state: absent
    persistent: present
  loop:
    - cramfs
    - freevxfs
    - jffs2
    - hfs
    - hfsplus
    - squashfs
```

---

## 🛠️ Security Tooling & NIST Alignment

| Control Family | Tool / Implementation | Purpose |
|----------------|----------------------|---------|
| **AC‑2** Account Management | SSHd configuration, `fail2ban` | Restrict root access, enforce key‑based auth, brute‑force protection |
| **CM‑7** Least Functionality | `modprobe` blacklisting | Disable unused kernel modules & filesystems |
| **SC‑7** Boundary Protection | UFW, provider‑specific iptables rules | Default‑deny firewall, cloud provider hardening |
| **SI‑4** System Monitoring | `auditd`, `crowdsec` IPS | Real‑time audit trail + collaborative intrusion prevention |
| **AU‑12** Audit Generation | `auditd` rules, centralized logging | Compliance‑ready audit records |
| **SC‑28** Data at Rest | Ansible Vault | Secrets via Vault; disk encryption handled at provisioning (audit only) |

**Provider‑Agnostic Design**:  
The suite auto‑detects `cloud_provider` (`hetzner`/`oci`) and applies provider‑specific hardening (e.g., OCI iptables killswitch, Hetzner rate‑limited SSH).

**Built for SRE & FinOps**:  
- **Idempotent** – safe to run repeatedly  
- **Tagged roles** – selective execution (`--tags nist,cm‑7,si‑4`)  
- **Cost‑aware** – no unnecessary packages, minimal footprint  

---
## 📚 Documentation

Complete documentation for this project:

| Document | Purpose |
|----------|---------|
| **[ARCHITECTURE.md](ARCHITECTURE.md)** | System design, component architecture, NIST control mapping, and technical decisions |
| **[ROADMAP.md](ROADMAP.md)** | Development roadmap with v1.1.0+ features and commercial platform plans |
| **[CHANGELOG.md](CHANGELOG.md)** | Version history and detailed release notes for v1.0.0 |
| **[CONTRIBUTING.md](CONTRIBUTING.md)** | Contribution guidelines, development setup, and code quality standards |
| **[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)** | Community guidelines and expected behavior |
| **[RELEASE.md](RELEASE.md)** | Release procedure and validation checklist for maintainers |

---
## 📬 Contact & Brand

**Maintained by:** Miguel Lozano — Site Reliability Engineer & FinOps Architect  
**Brand:** Developmi | **GitHub:** [Miguel-DevOps](https://github.com/Miguel-DevOps)

* **Website:** [developmi.com](https://developmi.com)
* **Philosophy:** *Security is not a feature; it is the baseline.*
* **Role:** Hybrid Cloud SRE & FinOps Architecture
* **Inquiries:** Infrastructure Security & Cost Optimization Consulting
---

© 2026 Miguel Lozano. All rights reserved.