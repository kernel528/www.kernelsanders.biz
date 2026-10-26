#!/usr/bin/env sh
set -eu

: "${DRONE_BUILD_NUMBER:?Drone build number is required}"
: "${DRONE_BUILD_EVENT:?Drone build event is required}"
: "${DRONE_BRANCH:?Drone branch is required}"
: "${DRONE_COMMIT_SHA:?Commit SHA is required}"
: "${WEBSITE_IMAGE_REPO:?Website image repository is required}"
: "${DOCKER_USERNAME:?Docker username secret is required}"
: "${DOCKER_PASSWORD:?Docker password secret is required}"

if [ "$DRONE_BUILD_EVENT" != push ] || [ "$DRONE_BRANCH" != testing ]; then
  printf '%s\n' 'Website candidates may only be published for pushes to testing.' >&2
  exit 1
fi

image_id=$(cat .drone-website-image-id)
candidate_tag=$(cat .drone-website-image-tag)
candidate_commit=$(cat .drone-website-commit)
site_version=$(awk '/^\* / { version = $2 } END { print version }' VERSION.md)
expected_tag="testing-${site_version}-drone-build-${DRONE_BUILD_NUMBER}-amd64"

if [ "$candidate_commit" != "$DRONE_COMMIT_SHA" ] || [ "$candidate_tag" != "$expected_tag" ]; then
  printf '%s\n' 'Website candidate metadata does not match this Drone build.' >&2
  exit 1
fi

docker image inspect "$image_id" >/dev/null
image_ref="${WEBSITE_IMAGE_REPO}:${candidate_tag}"
docker_config=$(mktemp -d)
cleanup() {
  rc=$?
  trap - EXIT
  rm -rf "$docker_config" || rc=1
  rm -f .drone-website-image-id .drone-website-image-tag .drone-website-commit || rc=1
  exit "$rc"
}
trap cleanup EXIT
export DOCKER_CONFIG=$docker_config
printf '%s' "$DOCKER_PASSWORD" | docker login --username "$DOCKER_USERNAME" --password-stdin

if manifest_output=$(docker manifest inspect "$image_ref" 2>&1); then
  printf 'Refusing to overwrite existing website candidate %s.\n' "$image_ref" >&2
  exit 1
else
  case "$manifest_output" in
    *MANIFEST_UNKNOWN*|*"manifest unknown"*|*"no such manifest"*) ;;
    *) printf 'Could not verify website candidate tag is unused: %s\n' "$manifest_output" >&2; exit 1 ;;
  esac
fi

docker image tag "$image_id" "$image_ref"
if [ "$(docker image inspect --format '{{.Id}}' "$image_ref")" != "$image_id" ]; then
  printf '%s\n' 'Website candidate tag does not reference the tested image ID.' >&2
  exit 1
fi
docker image push "$image_ref"
