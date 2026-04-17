<div align="center">

<img src="docs/assets/nist-hardening-suite.png" width="180" alt="NIST Hardening Suite logo" />

# NIST Hardening Suite | Developmi

_Enterprise-grade Ansible hardening for NIST-aligned Debian and Ubuntu infrastructure._

![Python 3.14](https://img.shields.io/badge/Python-3.14-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Ansible Core 2.20.4](https://img.shields.io/badge/Ansible_Core-2.20.4-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![Docker Ready](https://img.shields.io/badge/Docker-Ready-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Standard NIST 800-53](https://img.shields.io/badge/Standard-NIST_800--53-0B5CAD?style=for-the-badge)
![Status Production Active](https://img.shields.io/badge/Status-Production_Active-success?style=for-the-badge)
![License MIT](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)
![Maintainer Miguel Lozano](https://img.shields.io/badge/Maintainer-Miguel_Lozano-black?style=for-the-badge)
![Role Cloud & Infrastructure Engineer](https://img.shields.io/badge/Role-Cloud_%26_Infrastructure_Engineer-black?style=for-the-badge)
![CI GitHub Actions](https://img.shields.io/badge/CI-GitHub_Actions-blue?style=for-the-badge&logo=githubactions&logoColor=white)
![Provider Hetzner](https://img.shields.io/badge/Provider-Hetzner_Bare_Metal-DC1F26?style=for-the-badge)
![Provider Oracle Cloud](https://img.shields.io/badge/Provider-Oracle_Cloud-F80000?style=for-the-badge)

</div>

> **The script is free. Peace of mind is not.**
>
> This repository delivers a reproducible hardening baseline, zero-trust access patterns, and optional containerized application bundles for managed infrastructure.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Value Snapshot for CTO/CFO](#value-snapshot-for-ctocfo)
- [FinOps Case Study (Nuntu)](#finops-case-study-nuntu)
- [Field Validation Evidence](#field-validation-evidence)
- [Compliance & Standards](#compliance--standards)
- [Quick Start](#quick-start)
- [Operations with Make](#operations-with-make)
- [Architecture](#architecture)
- [Docker & Deployment](#docker--deployment)
- [Configuration & Secrets](#configuration--secrets)
- [Validation & Quality Gates](#validation--quality-gates)
- [Documentation Guide](#documentation-guide)
- [Contact & Support](#contact--support)

---

## Overview

NIST Hardening Suite is an Ansible-based infrastructure automation project focused on establishing a secure, auditable, and repeatable baseline across mixed-host environments.

It is designed to standardize the security posture of:

- **Brain nodes** for central services, ingress, and observability.
- **Muscle nodes** for workload execution and optional edge services.
- **Optional Docker Compose applications** under `recommended_apps/`.

The project aligns to **NIST 800-53** controls and emphasizes secrets handling, least privilege, hardened networking, and operational repeatability.

---

## Features

- 🛡️ **Security-first hardening** with SSH restrictions, firewall controls, audit logging, CrowdSec integration, and Vault-backed secrets.
- 🔐 **Zero-trust networking** through Tailscale ACL-driven access and minimized public exposure.
- 🧱 **Modular architecture** using Ansible roles for security, Docker orchestration, observability, compliance, ingress, and Portainer edge operations.
- 📦 **Optional application bundles** for Chatwoot, Metabase, n8n, Twenty CRM, and Uptime Kuma.
- 📈 **Operational visibility** with exporter and observability stack support when capacity allows.
- 🧪 **Validation gates** executed through Make targets (uv-backed) for linting, syntax checks, and secret scanning.
- 🧭 **Documented operating model** with commands centralized in `docs/operations/COMMANDS.md`.

---

## Value Snapshot for CTO/CFO

In less than 30 seconds:

- **Cost Control:** Designed for self-hosted operation on VPS/Bare Metal to avoid linear SaaS cost growth.
- **Security Baseline:** NIST-aligned hardening with zero-trust networking and auditable controls.
- **Data Sovereignty:** Sensitive workloads stay in infrastructure you control.
- **Cloud-Exit Ready:** Portable Ansible playbooks and provider-agnostic architecture reduce lock-in.
- **Operational Predictability:** Pull-based management model and Make-driven runbooks reduce change risk.

---

## FinOps Case Study (Nuntu)

This project pattern has been applied to a real-world migration scenario (codenamed **Nuntu**) focused on sovereignty, security, and OpEx reduction.

### Business problem

- SaaS sprawl with linear OpEx growth by headcount.
- Data processed in third-party multi-tenant platforms.
- Vendor/API dependence creating operational fragility.

### Implemented approach

- Sovereign self-hosted stack on high-performance VPS fleet.
- Pull-based operations model (Portainer Edge pattern).
- Caddy + WAF perimeter with hardened default-deny posture.
- Security automation and compliance-oriented runbooks.

### Measured outcomes (reported case)

| Metric                 | Before (SaaS Sprawl) | After (Sovereign Self-Hosted)        | Impact                     |
| ---------------------- | -------------------- | ------------------------------------ | -------------------------- |
| Annual Software OpEx   | $X (baseline)        | $0.3X                                | **-70%**                   |
| Platform Uptime (Prod) | ~99.5%               | 99.8%                                | Higher reliability         |
| Data Sovereignty       | 0%                   | 100%                                 | Full control               |
| WAF Efficacy           | N/A                  | >99% block rate, <1% false positives | Enterprise-grade perimeter |
| Incident Response Time | Hours/Days           | Minutes                              | Stronger resilience        |
| Vendor Risk            | Critical             | Negligible                           | Supply-chain risk reduced  |

> **Scope note:** This case study is a field implementation narrative and not a vendor benchmark report. Results depend on workload, architecture, and governance discipline.

---

## Field Validation Evidence

Current documented execution evidence in this repository corresponds to a lab/staging scope with:

- **1 Brain node**
- **2 Muscle nodes**

This is intentionally presented as operational proof-of-execution while broader fleet rollouts are scheduled.

### Deployment proof screenshots

![Base hardening deployment evidence](docs/assets/make-deploy.png)

![Stack deployment evidence (part 1)](docs/assets/make-deploy-stacks-1.png)

![Stack deployment evidence (part 2)](docs/assets/make-deploy-stacks-2.png)

![Monitoring deployment evidence](docs/assets/make-deploy-monitoring.png)

---

## Compliance & Standards

This repository is not just "NIST-themed". It includes implementation-grounded compliance references with auditable mappings and evidence workflows.

### Primary control coverage

- **NIST SP 800-53:** AC-2, CM-7, SC-7, SI-4, AU-12, and SC-28 (partial for full disk encryption).
- **NIST SP 800-207 (Zero Trust):** overlay-network control path, identity/tag-based access, and pull-based management pattern.
- **CIS Level 1 (generic Ubuntu/Debian alignment):** SSH baseline, firewall posture, brute-force mitigation, and audit telemetry.
- **DORA/ENS contextual mapping:** documented as technical-functional alignment for resilience and governance discussions.

### Where to audit compliance details

- Executive compliance posture: [docs/compliance/COMPLIANCE.md](docs/compliance/COMPLIANCE.md)
- Full technical control matrix: [docs/compliance/COMPLIANCE_MAPPINGS.md](docs/compliance/COMPLIANCE_MAPPINGS.md)
- Reproducible evidence workflow: [docs/compliance/AUDIT_EVIDENCE.md](docs/compliance/AUDIT_EVIDENCE.md)
- Authoritative references and citations: [docs/compliance/REGULATORY_REFERENCES.md](docs/compliance/REGULATORY_REFERENCES.md)

> **Important:** This project provides implementation evidence and technical mappings. Formal certification readiness still requires organization-specific legal, scope, and auditor validation.

---

## Quick Start

### Prerequisites

- `uv` for Python dependency and environment management.
- Python 3.14 or newer.
- SSH access to the target hosts.
- Ansible Galaxy network access for collection installation.
- Docker Compose only if you plan to run optional app bundles.

### Setup

```bash
git clone https://github.com/Miguel-DevOps/nist-hardening-suite.git
cd nist-hardening-suite
make sync
make install-collections
```

### Inventory

Create or customize your inventory before deployment:

```ini
[brain]
brain-1 ansible_host=YOUR_PUBLIC_IP ansible_user=root public_ip=YOUR_PUBLIC_IP

[muscle]
muscle-1 ansible_host=YOUR_PUBLIC_IP ansible_user=ubuntu public_ip=YOUR_PUBLIC_IP
```

### Secrets

Populate the Vault-backed secrets file and encrypt it before deployment:

```bash
make vault-init
make vault-encrypt
```

### Deploy

```bash
make validate
make deploy
make deploy-stacks
make deploy-monitoring
```

> **Note:** The canonical command surface lives in [docs/operations/COMMANDS.md](docs/operations/COMMANDS.md). Use `make` targets instead of raw playbook calls when possible.

---

## Operations with Make

Make is the official command interface for this project. Day-to-day operations should run through Make targets.

### High-frequency operator commands

```bash
make help
make sync
make install-collections
make validate
make deploy
make deploy-stacks
make deploy-monitoring
make verify-tailscale
make verify-crowdsec
make verify-observability
```

### Advanced and safety workflows

```bash
make deploy-tags PLAYBOOK=site.yml ANSIBLE_TAGS='nist,sc-7'
make deploy-skip-tags PLAYBOOK=site.yml ANSIBLE_SKIP_TAGS='tailscale,vpn'
make compliance
make nuke CONFIRM=DESTROY_ALL_INFRASTRUCTURE
```

Operational reference index:

- Primary runbook: [docs/operations/COMMANDS.md](docs/operations/COMMANDS.md)
- Production command-path controls: [docs/operations/PRODUCTION_COMMAND_AUDIT.md](docs/operations/PRODUCTION_COMMAND_AUDIT.md)
- Optional app operations: [docs/operations/apps/APP_RECOMMENDED_GUIDE.md](docs/operations/apps/APP_RECOMMENDED_GUIDE.md)

---

## Architecture

### Simplified Tree

```text
.
├── site.yml                 # Base hardening entry point
├── stacks.yml               # Management and application stack deployment
├── monitoring.yml           # Exporters and observability stack deployment
├── nuke.yml                 # Destructive cleanup workflow
├── inventory/               # Target host inventory definitions
├── group_vars/              # Shared and group-specific variables
├── roles/                   # Ansible roles for platform capabilities
├── recommended_apps/        # Optional Docker Compose application bundles
├── docs/                    # Operational, compliance, and project documentation
└── scripts/                 # Bootstrap and monitoring helpers
```

### Execution Flow

```mermaid
flowchart LR
  Operator[Operator] --> Make[Make Targets]
  Make --> Ansible[Ansible Playbooks]
  Ansible --> Vault[Encrypted Secrets]
  Ansible --> Hosts[Brain and Muscle Hosts]
  Hosts --> Docker[Optional Docker Compose Bundles]
  Hosts --> Security[Hardening, Compliance, and Monitoring]
```

The role structure is intentionally separated so security controls, Docker orchestration, observability, and ingress can evolve independently without coupling the baseline hardening path.

---

## Docker & Deployment

Docker is used for optional application stacks and observability services, not as the primary automation runtime.

### Run an Optional App

```bash
cd recommended_apps/n8n
cp .env.example .env
docker compose --env-file .env up -d
```

### Security Notes

- Prefer publishing services through the hardened ingress layer instead of exposing broad host ports.
- Keep `.env` files local and out of version control.
- Use the provided Vault workflow for sensitive runtime values.
- Optional app bundles are intended to run behind the project’s reverse proxy and network segmentation model.

> **Important:** There is no root-level Docker build context in the current repository. Container workflows are delivered through compose bundles under `recommended_apps/`.

---

## Configuration & Secrets

This project does not require a root `.env.example`. Sensitive inputs are handled through Ansible Vault in `group_vars/all/secrets.yml`, while application-specific compose bundles keep their own `.env.example` templates under `recommended_apps/`.

### Core Vault Template

```yaml
# group_vars/all/secrets.yml.example
vault_github_token: "GITHUB_TOKEN_GOES_HERE"
tailscale_auth_key: "tskey-client-XXXXXXXXXXXXXXXX"
portainer_edge_keys_by_node:
  brain-1: "PORTAINER_EDGE_KEY_FOR_BRAIN_1"
  muscle-1: "PORTAINER_EDGE_KEY_FOR_MUSCLE_1"
tailscale_acl_key: "tskey-client-YYYYYYYYYYYYYYYY"
tailscale_acl_client_id: "YOUR_TAILSCALE_OAUTH_CLIENT_ID"
caddy_acme_email: "ops@example.com"
```

### Optional Observability Values

These are required only when the observability stack is enabled:

- `observability_network_name`
- `observability_stack_host_ip`
- `observability_grafana_admin_user`
- `observability_grafana_admin_password`
- `observability_grafana_root_url`

### App-Level `.env.example` Files

- `recommended_apps/chatwoot/.env.example`
- `recommended_apps/metabase/.env.example`
- `recommended_apps/n8n/.env.example`
- `recommended_apps/twenty-crm/.env.example`
- `recommended_apps/uptime-kuma/.env.example`

---

## Validation & Quality Gates

The repository is validated through uv-managed tooling and Ansible-native checks.

```bash
make sync
make install-collections
make validate
make lint PLAYBOOK=site.yml
make precommit-run
```

Current quality gates include:

- YAML formatting validation.
- Ansible playbook syntax checks.
- Role and playbook linting.
- Secret detection with a tracked baseline.

> **Operational note:** `make lint` is intentionally strict and should be used before changes are promoted to shared environments.

---

## Documentation Guide

Use this map to find deep technical details quickly.

### Entry point

- Documentation index: [docs/README.md](docs/README.md)

### Architecture

- System design and security layering: [docs/architecture/ARCHITECTURE.md](docs/architecture/ARCHITECTURE.md)

### Operations

- Commands and runbooks: [docs/operations/COMMANDS.md](docs/operations/COMMANDS.md)
- Production audit trail for commands: [docs/operations/PRODUCTION_COMMAND_AUDIT.md](docs/operations/PRODUCTION_COMMAND_AUDIT.md)
- Recommended apps deployment guidance: [docs/operations/apps/APP_RECOMMENDED_GUIDE.md](docs/operations/apps/APP_RECOMMENDED_GUIDE.md)

### Compliance

- Executive compliance overview: [docs/compliance/COMPLIANCE.md](docs/compliance/COMPLIANCE.md)
- Control mapping matrix: [docs/compliance/COMPLIANCE_MAPPINGS.md](docs/compliance/COMPLIANCE_MAPPINGS.md)
- Audit evidence collection: [docs/compliance/AUDIT_EVIDENCE.md](docs/compliance/AUDIT_EVIDENCE.md)
- Regulatory source references: [docs/compliance/REGULATORY_REFERENCES.md](docs/compliance/REGULATORY_REFERENCES.md)

### Project governance

- Roadmap: [docs/project/ROADMAP.md](docs/project/ROADMAP.md)
- Changelog: [docs/project/CHANGELOG.md](docs/project/CHANGELOG.md)
- Release process: [docs/project/RELEASE.md](docs/project/RELEASE.md)
- Contribution standards: [docs/project/CONTRIBUTING.md](docs/project/CONTRIBUTING.md)
- Code of conduct: [docs/project/CODE_OF_CONDUCT.md](docs/project/CODE_OF_CONDUCT.md)

---

## Contact & Support

- **Maintained by:** Miguel Lozano | Developmi
- **Role:** Cloud & Infrastructure Engineer | FinOps & Bare Metal Specialist | AI Sovereignty Strategist under NIST/DORA Standards
- **Philosophy:** _Security is not a feature; it is the baseline._
- **Website:** [Developmi](https://developmi.com)
- **GitHub:** [Miguel-DevOps](https://github.com/Miguel-DevOps)
- **LinkedIn:** [Miguel Lozano](https://www.linkedin.com/in/miguel-dev-ops)

---

© 2026 Miguel Lozano. All rights reserved.
