# Repository Context

- Static site repo for `www.kernelsanders.biz`.
- Current release candidate: `2.3.0`, planned from `testing` then `main`.
- Release-candidate base image: `kernel528/httpd:2.4.69-3.24.3_1`.
- The site is served on standard HTTP port `80`.
- Key files: `htdocs/index.html`, `htdocs/style.css`, `Dockerfile`, `VERSION.md`, `scripts/inject-version.sh`, `httpd-foreground`, `.drone.yml`.
- CI: PRs into `testing` run lint/build/smoke tests with isolated build-specific containers; tags from `main` publish releases.
- Deployment: update `docker-swarm/stacks/kernelsanders-stack.yml` after release, then redeploy through Portainer UI.
- Update `VERSION.md`, `Dockerfile`, and hardcoded runtime text together on base-image bumps.
