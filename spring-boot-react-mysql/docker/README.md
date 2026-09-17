This folder contains helper files for Docker secrets and configs.

Secrets
- Two sample secret files are included under docker/secrets/*.sample.
- Do NOT commit real secrets. Create real secret files or use `docker secret create` in swarm mode.

Using Docker Compose (local/testing)
- The repo's `docker-compose.yml` references the sample secret files. Replace the sample files or create real secrets before running `docker compose up`.

Notes
- The Spring Boot image was changed to a shell-capable JRE so the entrypoint can read secrets mounted at `/run/secrets/...`.
- NGINX config is referenced as a Docker `config` (useful with swarm stacks).
