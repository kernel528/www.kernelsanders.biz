# Repository Guidelines

## Project Structure & Module Organization
- `htdocs/` contains the static site assets (`index.html`, `style.css`).
- `Dockerfile` builds the Apache image and copies `htdocs/*` into the web root.
- `httpd-foreground` is the container entrypoint script.
- `VERSION.md` tracks release notes and version history.
- `package.json` defines lint tooling and scripts; lint configs live in `.htmlhintrc` and `.stylelintrc.json`.

## Build, Test, and Development Commands
- `docker image build -t kernel528/www.kernelsanders.biz:<version> --platform linux/amd64 -f Dockerfile .` builds the site image.
- `docker run --rm -p 8080:80 kernel528/www.kernelsanders.biz:<version>` runs the container locally for a quick visual check.
- `docker image push kernel528/www.kernelsanders.biz:<version>` publishes the image to Docker Hub.
- `npm install` installs linting dependencies.
- `npm run lint` runs HTML/CSS linting locally.

## Coding Style & Naming Conventions
- Use 4-space indentation in HTML/CSS and keep tags/attributes lowercase.
- Keep static assets in `htdocs/`; update `style.css` for visual changes and `index.html` for content.
- When bumping versions, update `VERSION.md` and the footer text in `htdocs/index.html` together.
- Commit `package-lock.json` when dependencies change, and keep `node_modules/` untracked.

## Testing Guidelines
- CI includes HTML/CSS linting, link checks, and a container smoke test in the Drone `testing` pipeline.
- For local validation, run `npm run lint` and smoke test with the Docker run command above.

## Commit & Pull Request Guidelines
- Commit messages are short and descriptive (e.g., "Updated base image to kernel528/httpd:2.4.66-3.23.2").
- PRs should include a brief description, any version bumps, and a screenshot when UI changes occur.
- CI is handled by Drone; merges to `main` trigger a build, and tagged releases publish versions.
- Code ownership is defined in `CODEOWNERS` (`@kernel528`).

## Security & Configuration Notes
- The base image is pinned in `Dockerfile`; update the base image and the version notes together to keep releases reproducible.
