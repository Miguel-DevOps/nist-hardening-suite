# Recommended Applications Guide

This repository keeps the core platform opinionated and secure:
- Caddy is the default ingress boundary.
- Optional applications are decoupled from core roles.
- Portainer remains the operator UX, but security defaults are enforced in app templates.

## Why This Model

For enterprise-grade open source DX, the best balance is:
- Core roles: stable, deterministic, minimal attack surface.
- Optional apps: plug-and-play, separately versioned in `recommended_apps/`.
- Exposure model: Caddy-first over `public_net`, not direct host-port exposure.

This avoids forcing all developers to run every app while preserving a consistent security baseline.

## Directory Layout

- `recommended_apps/uptime-kuma/docker-compose.yml`
- `recommended_apps/uptime-kuma/.env.example`

## Uptime Kuma Standard

The provided compose uses these defaults:
- No host `ports` mapping.
- Internal service exposure only (`expose: 3001`).
- Attachment to shared external network `public_net` for Caddy reverse-proxy routing.
- Persistent data under `/srv/app/recommended-apps/uptime-kuma/data`.

## Deployment Flow (Portainer or Docker Compose)

1. Create app data directory on host:
   `mkdir -p /srv/app/recommended-apps/uptime-kuma/data`
2. Copy `.env.example` into your runtime env source.
3. Deploy compose from `recommended_apps/uptime-kuma/docker-compose.yml`.
4. Add a Caddy route that proxies to `uptime-kuma:3001` on `public_net`.
5. Complete first-time setup from browser via Caddy URL (`/setup-database`).

## Temporary Bootstrap Port (Only If Needed)

If you must bypass Caddy during initial testing:
- Use a temporary compose override that publishes `3001`.
- Bind only to trusted interfaces (for example Tailscale IP), never to unrestricted public interfaces unless firewall rules enforce scope.
- Remove the direct port publish after setup.

## Security Notes

- Uptime Kuma initial setup is web-only (no official CLI bootstrap flow).
- Keep direct app ports closed by default.
- Enforce access policy at Caddy and firewall layers.
- Keep optional apps out of core hardening roles to prevent accidental exposure during baseline runs.
