#!/usr/bin/env sh
set -eu

: "${DRONE_BUILD_NUMBER:?Drone build number is required}"
: "${DRONE_BUILD_EVENT:?Drone build event is required}"
: "${DRONE_BRANCH:?Drone branch is required}"
: "${DRONE_COMMIT_SHA:?Drone commit SHA is required}"

if [ "$DRONE_BUILD_EVENT" != push ] || [ "$DRONE_BRANCH" != testing ]; then
  printf '%s\n' 'Website candidates are allowed only on pushes to testing.' >&2
  exit 1
fi

base_ref=$(awk '$1 == "FROM" && $2 ~ /^kernel528\/httpd:/ { print $2; exit }' Dockerfile)
base_tag=${base_ref##*:}
httpd_version=${base_tag%%-*}
alpine_tag=${base_tag##*-}
expected_alpine=${alpine_tag%_*}
site_version=$(awk '/^\* / { version = $2 } END { print version }' VERSION.md)
image="localhost/website-candidate:${DRONE_BUILD_NUMBER}-${DRONE_COMMIT_SHA}"
candidate_tag="testing-${site_version}-drone-build-${DRONE_BUILD_NUMBER}-amd64"

if [ -z "$base_tag" ] || [ -z "$expected_alpine" ] || [ -z "$httpd_version" ] || [ -z "$site_version" ]; then
  printf '%s\n' 'Could not determine the pinned HTTPD base or site version.' >&2
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
printf 'Website candidate image ID: %s\n' "$image_id"
printf 'Website candidate tag after publish: %s\n' "$candidate_tag"
scripts/ci-smoke-website-image.sh "$image_id" "$expected_alpine" "$httpd_version" "$site_version"

umask 077
printf '%s\n' "$image_id" > .drone-website-image-id
printf '%s\n' "$candidate_tag" > .drone-website-image-tag
printf '%s\n' "$DRONE_COMMIT_SHA" > .drone-website-commit
