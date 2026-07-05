# Repository Guidelines

## Agent Instructions
- Read `README.md` first.
- Read `docs/current-work.md` if present.
- Read the relevant project profile from `~/Projects/Engineering/projects/<name>/`.
- Keep changes focused.
- Do not make broad refactors without asking.
- Run the smallest relevant test/build first.
- At session close, update `ai-handoff.md`.

## Scope
- `htdocs/` is the site source.
- `Dockerfile`, `httpd-foreground`, and `VERSION.md` control the image build and release versioning.

## Workflow
- Start work from `testing`.
- Keep version bumps consistent across `VERSION.md` and any hardcoded runtime text in `htdocs/index.html`.
- Update the base image and release notes together.

## Validation
- `npm run lint`

## Style
- Use 4-space indentation.
- Keep HTML tags and attributes lowercase.
- Keep `node_modules/`, logs, `.DS_Store`, and IDE files untracked.

## PRs
- Commit messages should be short and descriptive.
- PRs should mention version bumps and UI screenshots when relevant.
- Drone handles CI and publishing.
