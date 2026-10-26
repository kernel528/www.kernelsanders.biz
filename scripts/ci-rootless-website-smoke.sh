#!/usr/bin/env sh
set -eu

: "${DRONE_BUILD_NUMBER:?Drone build number is required}"
: "${DRONE_COMMIT_SHA:?Drone commit SHA is required}"

image="localhost/website-ci:${DRONE_BUILD_NUMBER}-${DRONE_COMMIT_SHA}"
base_ref=$(awk '$1 == "FROM" && $2 ~ /^kernel528\/httpd:/ { print $2; exit }' Dockerfile)
base_tag=${base_ref##*:}
httpd_version=${base_tag%%-*}
alpine_tag=${base_tag##*-}
expected_alpine=${alpine_tag%_*}
site_version=$(awk '/^\* / { version = $2 } END { print version }' VERSION.md)

if [ -z "$base_tag" ] || [ -z "$httpd_version" ] || [ -z "$expected_alpine" ] || [ -z "$site_version" ]; then
  printf '%s\n' 'Could not determine the pinned HTTPD base or site version.' >&2
  exit 1
fi

cleanup() {
  rc=$?
  trap - EXIT
  if docker image inspect "$image" >/dev/null 2>&1; then
    docker image rm --no-prune "$image" || rc=1
  fi
  exit "$rc"
}
trap cleanup EXIT

docker build --pull --no-cache --tag "$image" .
image_id=$(docker image inspect --format '{{.Id}}' "$image")
printf 'Rootless website image ID: %s\n' "$image_id"
scripts/ci-smoke-website-image.sh "$image_id" "$expected_alpine" "$httpd_version" "$site_version"
