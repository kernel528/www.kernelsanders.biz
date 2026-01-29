[![Drone Build Status](http://drone.kernelsanders.biz:8080/api/badges/kernel528/www.kernelsanders.biz/status.svg?ref=refs/heads/main)](http://drone.kernelsanders.biz:8080/kernel528/www.kernelsanders.biz)
[![Latest Version](https://img.shields.io/github/v/tag/kernel528/www.kernelsanders.biz)](https://github.com/kernel528/www.kernelsanders.biz/releases/latest)
[![Docker Pulls](https://img.shields.io/docker/pulls/kernel528/www.kernelsanders.biz)](https://hub.docker.com/r/kernel528/www.kernelsanders.biz)
[![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/kernel528/www.kernelsanders.biz)](https://hub.docker.com/r/kernel528/www.kernelsanders.biz)
[![Docker Image Version (latest by date)](https://img.shields.io/docker/v/kernel528/www.kernelsanders.biz)](https://hub.docker.com/r/kernel528/www.kernelsanders.biz)

# www.kernelsanders.biz
This repo contains the source code for the www.kernelsanders.biz static website and its Docker image.

## Setup
* This uses the `kernel528/httpd:2.4.66-3.23.3` image as the base Docker image.
* Site content is located in `./htdocs`.
* The Dockerfile copies `htdocs/` into the Apache web root and injects the site version during build.
* Drone builds the image when a PR is merged to `main` and a tag release is created.
* On merges to `main`, Drone reports OS and httpd versions and curls the homepage.

## Project Layout
* `htdocs/` - Static site assets (`index.html`, `style.css`).
* `Dockerfile` - Builds the Apache image and copies site assets.
* `httpd-foreground` - Container entrypoint script.
* `scripts/inject-version.sh` - Injects the current version from `VERSION.md` into `htdocs/index.html`.
* `VERSION.md` - Release notes and version history.
* `package.json` - Lint and dev server scripts.

## To Do
* Wire up Slack notifications in Drone.
* Refresh homepage content and link stacks.
* Capture updated screenshots for `screenshots/`.

## Local Development
* Install dependencies: `npm install`
* Lint HTML/CSS: `npm run lint`
* Run a dev server (port 8081): `npm run dev`

## CI Behavior
* `testing` pipeline runs on pull requests to the `testing` branch and runs linting, builds testing images, and smoke tests.
* `main` pipeline runs on tags from the `main` branch and builds the release images.

## How to Build Locally and Push
* Build the Docker image:
    * `docker image build -t kernel528/www.kernelsanders.biz:<version> --platform linux/amd64 -f Dockerfile .`
* Push the image:
    * `docker image push kernel528/www.kernelsanders.biz:<version>`

## Release Checklist
* Update the base image in `Dockerfile` if needed.
* Bump the version and notes in `VERSION.md`.
* Ensure the footer version in `htdocs/index.html` matches `VERSION.md` (injected at build time).

### Author:  kernel528@gmail.com
