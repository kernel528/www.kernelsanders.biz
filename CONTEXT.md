# Repository Context

- Static site repo for `www.kernelsanders.biz`.
- Current release: `2.1.0`.
- Base image: `kernel528/httpd:2.4.68-3.24.1`.
- Deployed stack image: `kernel528/www.kernelsanders.biz:2.1.0` on host port `81`.
- Key files: `htdocs/index.html`, `htdocs/style.css`, `Dockerfile`, `VERSION.md`, `scripts/inject-version.sh`, `httpd-foreground`, `.drone.yml`.
- CI: `testing` lint/build/smoke test with `docker:27-cli`; `main` publishes tagged releases.
- Update `VERSION.md`, `Dockerfile`, and hardcoded runtime text together on base-image bumps.
