# Repository Context

- Static site repo for `www.kernelsanders.biz`.
- Current release: `2.1.1`.
- Planned release: `2.2.0` from `testing`, then `main`.
- Release-candidate base image: `kernel528/httpd:2.4.68-3.24.1_1`.
- Deployed stack image: `kernel528/www.kernelsanders.biz:2.1.1` on host port `81`.
- Key files: `htdocs/index.html`, `htdocs/style.css`, `Dockerfile`, `VERSION.md`, `scripts/inject-version.sh`, `httpd-foreground`, `.drone.yml`.
- CI: PRs into `testing` run lint/build/smoke tests with isolated build-specific containers; tags from `main` publish releases.
- Deployment: update `docker-swarm/stacks/kernelsanders-stack.yml` after release, then redeploy through Portainer UI.
- Update `VERSION.md`, `Dockerfile`, and hardcoded runtime text together on base-image bumps.
