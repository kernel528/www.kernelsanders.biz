# Repository Guidelines

## Agent Instructions
- Read `README.md` first.
- Read `docs/current-work.md` if present.
- Read the relevant project profile from `~/Projects/Agentic_Engineering/projects/www-kernelsanders-biz/`.
- Keep changes focused.
- Do not make broad refactors without asking.
- Run the smallest relevant test/build first.
- At session close, record validation and remaining release/deployment steps in the PR or handoff notes when present.

## Scope
- `htdocs/` is the site source.
- `Dockerfile`, `httpd-foreground`, and `VERSION.md` control the image build and release versioning.

## Workflow
- Treat `testing` as the policy branch and start working branches from current `origin/testing`.
- Merge working branches into `testing` only after local checks and the Drone testing pipeline pass.
- After `testing` is validated, open a PR from `testing` to `main`.
- Create release tags only from merged `main`; do not use testing images for Swarm deployment.
- Keep version bumps consistent across `VERSION.md` and any hardcoded runtime text in `htdocs/index.html`.
- Update the base image and release notes together.
- After the release image resolves, update `docker-swarm/stacks/kernelsanders-stack.yml`; deployment is performed through the Portainer UI.

## Validation
- `npm ci`
- `npm audit`
- `npm run lint`
- Build the release candidate image and verify the homepage from a disposable container.

## Style
- Use 4-space indentation.
- Keep HTML tags and attributes lowercase.
- Keep `node_modules/`, logs, `.DS_Store`, and IDE files untracked.

## PRs
- Commit messages should be short and descriptive.
- PRs should mention version bumps and UI screenshots when relevant.
- Dependabot version PRs should target `testing`; retarget security PRs from `main` to `testing` before merge.
- Drone handles CI and publishing.
