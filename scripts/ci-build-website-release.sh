#!/usr/bin/env sh
set -eu

: "${DRONE_BUILD_NUMBER:?Drone build number is required}"
: "${DRONE_BUILD_EVENT:?Drone build event is required}"
: "${DRONE_TAG:?Release tag is required}"
: "${DRONE_COMMIT_REF:?Git ref is required}"
: "${DRONE_COMMIT_SHA:?Commit SHA is required}"

if [ "$DRONE_BUILD_EVENT" != tag ] || [ "$DRONE_COMMIT_REF" != "refs/tags/$DRONE_TAG" ]; then
  printf '%s\n' 'Website release builds require their matching Git tag event.' >&2
  exit 1
fi

base_ref=$(awk '$1 == "FROM" && $2 ~ /^kernel528\/httpd:/ { print $2; exit }' Dockerfile)
base_tag=${base_ref##*:}
httpd_version=${base_tag%%-*}
alpine_tag=${base_tag##*-}
expected_alpine=${alpine_tag%_*}
site_version=$(awk '/^\* / { version = $2 } END { print version }' VERSION.md)
image="localhost/website-release:${DRONE_BUILD_NUMBER}-${DRONE_COMMIT_SHA}"

if [ "$DRONE_TAG" != "$site_version" ]; then
  printf 'Website release tag mismatch: expected %s, got %s.\n' "$site_version" "$DRONE_TAG" >&2
  exit 1
fi

attempt=0
until docker info >/dev/null 2>&1; do
  attempt=$((attempt + 1))
  if [ "$attempt" -ge 60 ]; then
    printf '%s\n' 'Docker-in-Docker service did not become ready.' >&2
    exit 1
  fi
  sleep 1
done

docker build --pull --no-cache --tag "$image" .
image_id=$(docker image inspect --format '{{.Id}}' "$image")
printf 'Website release source commit: %s\n' "$DRONE_COMMIT_SHA"
printf 'Website release tag: %s\n' "$DRONE_TAG"
printf 'Website release image ID: %s\n' "$image_id"
scripts/ci-smoke-website-image.sh "$image_id" "$expected_alpine" "$httpd_version" "$site_version"

umask 077
printf '%s\n' "$image_id" > .drone-website-image-id
printf '%s\n' "$DRONE_TAG" > .drone-website-release-tag
printf '%s\n' "$DRONE_COMMIT_SHA" > .drone-website-commit
