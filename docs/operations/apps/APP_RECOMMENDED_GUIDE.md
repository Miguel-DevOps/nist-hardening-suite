# Recommended Applications Hardening & Deployment Guide (2026)

This guide defines the standards and procedures for deploying optional applications in the NIST Hardening Suite, ensuring consistency, security, and maintainability across all recommended apps.

## 1. Stack Consistency & Security Checklist

- **Unified stack:** All recommended apps must use Postgres 17+ and Valkey 9+ (Redis is not allowed; Valkey is a drop-in replacement).
- **No hardcoded values:** All Docker images, credentials, and service parameters must be set via `.env.example` files. No secrets or passwords in version control.
- **Explicit image tags:** Use only stable, explicit Docker image tags (no `latest`).
- **Consistent service names:** Dependent services (e.g., database, cache) must use consistent hostnames and environment variables across all apps.
- **Documented upgrade/migration:** Each app must include notes for upgrading images and migrating data (e.g., Redis to Valkey).
- **Backup & restore:** Each app must document persistent data locations and backup/restore procedures.
- **Security best practices:** Strong passwords, secret rotation, and network restrictions are required. No direct host port exposure by default.

## 2. General Deployment Model

- **Caddy as default ingress:** All apps are exposed via Caddy reverse proxy on the `public_net` Docker network. No direct host port mapping unless strictly required for bootstrap/testing.
- **Portainer for operator UX:** Portainer is the default management UI, but all app templates must enforce security defaults.
- **Plug-and-play:** Optional apps are decoupled from core roles and live in `recommended_apps/`, each with its own `docker-compose.yml` and `.env.example`.

## 3. Directory Layout Example

```
recommended_apps/
   chatwoot/
      docker-compose.yml
      .env.example
   n8n/
      docker-compose.yml
      .env.example
   twenty-crm/
      docker-compose.yml
      .env.example
   uptime-kuma/
      docker-compose.yml
      .env.example
```

## 4. Deployment Flow (Portainer or Docker Compose)

1. Copy the `.env.example` for the app you want to deploy and fill in all required variables (do not use real secrets in version control).
2. Create persistent data directories as needed (see each app's compose and documentation).
3. Deploy the app using Portainer or `docker compose`:
   - `docker compose --env-file .env up -d`
4. Add a Caddy route to proxy the app's internal port on `public_net`.
5. Complete any first-time setup via the app's web UI (never expose setup ports to the public internet).

## 5. Security & Hardening Notes

- **No Redis:** All apps must use Valkey for cache/session storage if required. Update environment variables and service names accordingly.
- **No hardcoded secrets:** All sensitive values must be set via environment variables and never committed to git.
- **No direct port exposure:** Only expose services via Caddy on `public_net`. Use `expose:` in compose, not `ports:`.
- **Temporary port exposure:** If you must expose a port for initial setup, bind only to trusted interfaces and remove after setup.
- **Backup:** Document and automate backup of persistent volumes for each app.
- **Update instructions:** Each app should include notes on how to safely upgrade images and migrate data if needed.

## 6. n8n Queue Mode (Production Guidance)

- n8n must be deployed in **queue mode** for production environments. This enables distributed job processing with dedicated workers, improving reliability and scalability.
- **Queue mode** requires a Valkey (or Redis-compatible) backend and is fully production ready.
- **Single mode** (no queue/workers) is not recommended for production, as it does not support horizontal scaling or robust job management.

## 7. Example: Uptime Kuma (Pattern for All Apps)

- No host `ports` mapping; only `expose: 3001`.
- Attached to `public_net` for Caddy routing.
- Persistent data under `/srv/app/recommended-apps/uptime-kuma/data`.
- All variables (including image tags) set via `.env.example`.

## 8. Example: Chatwoot (Pattern for All Apps)

- Uses Postgres 17+ and Valkey 9+ (no Redis service).
- All service images and credentials parameterized in `.env.example`.
- `REDIS_URL` must point to Valkey, not Redis.

## 9. Example: n8n and TwentyCRM

- Both use Postgres 17+ and Valkey 9+ (if cache required).
- All images and credentials parameterized in `.env.example`.
- No hardcoded values in compose files.

## 10. Maintenance & Upgrades

- Always update `.env.example` and compose files together.
- Document any breaking changes or migration steps in the app's README or comments.
- Regularly review for security updates to base images and dependencies.

---

Miguel Lozano, 2026
