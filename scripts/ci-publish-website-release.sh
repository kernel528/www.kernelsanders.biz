#!/usr/bin/env sh
set -eu

: "${DRONE_BUILD_EVENT:?Drone build event is required}"
: "${DRONE_TAG:?Release tag is required}"
: "${DRONE_COMMIT_REF:?Git ref is required}"
: "${DRONE_COMMIT_SHA:?Commit SHA is required}"
: "${WEBSITE_IMAGE_REPO:?Website image repository is required}"
: "${DOCKER_USERNAME:?Docker username secret is required}"
: "${DOCKER_PASSWORD:?Docker password secret is required}"

if [ "$DRONE_BUILD_EVENT" != tag ] || [ "$DRONE_COMMIT_REF" != "refs/tags/$DRONE_TAG" ]; then
  printf '%s\n' 'Website release publication requires its matching Git tag event.' >&2
  exit 1
fi

image_id=$(cat .drone-website-image-id)
release_tag=$(cat .drone-website-release-tag)
release_commit=$(cat .drone-website-commit)
site_version=$(awk '/^\* / { version = $2 } END { print version }' VERSION.md)

if [ "$release_tag" != "$DRONE_TAG" ] || [ "$release_tag" != "$site_version" ] || \
   [ "$release_commit" != "$DRONE_COMMIT_SHA" ]; then
  printf '%s\n' 'Website release metadata does not match the Drone tag, source commit, or VERSION.md.' >&2
  exit 1
fi

case "$image_id" in
  sha256:*) ;;
  *) printf '%s\n' 'Website release artifact does not contain an immutable image ID.' >&2; exit 1 ;;
esac

docker image inspect "$image_id" >/dev/null
release_ref="${WEBSITE_IMAGE_REPO}:${release_tag}"
docker_config=$(mktemp -d)
cleanup() {
  rc=$?
  trap - EXIT
  rm -rf "$docker_config" || rc=1
  rm -f .drone-website-image-id .drone-website-release-tag .drone-website-commit || rc=1
  exit "$rc"
}
trap cleanup EXIT
export DOCKER_CONFIG=$docker_config
printf '%s' "$DOCKER_PASSWORD" | docker login --username "$DOCKER_USERNAME" --password-stdin

if manifest_output=$(docker manifest inspect "$release_ref" 2>&1); then
  printf 'Refusing to overwrite immutable website release %s.\n' "$release_ref" >&2
  exit 1
else
  case "$manifest_output" in
    *MANIFEST_UNKNOWN*|*"manifest unknown"*|*"no such manifest"*) ;;
    *) printf 'Could not verify website release tag is unused: %s\n' "$manifest_output" >&2; exit 1 ;;
  esac
fi

docker image tag "$image_id" "$release_ref"
if [ "$(docker image inspect --format '{{.Id}}' "$release_ref")" != "$image_id" ]; then
  printf '%s\n' 'Website release tag is not attached to the tested image ID.' >&2
  exit 1
fi
if push_output=$(docker image push "$release_ref" 2>&1); then
  printf '%s\n' "$push_output"
else
  printf '%s\n' "$push_output" >&2
  exit 1
fi
release_digest=$(printf '%s\n' "$push_output" | awk '$2 == "digest:" { print $3; exit }')
case "$release_digest" in
  sha256:*) printf 'Immutable website release digest: %s\n' "$release_digest" ;;
  *) printf '%s\n' 'Registry push succeeded without reporting a manifest digest.' >&2; exit 1 ;;
esac

alias_ref="${WEBSITE_IMAGE_REPO}:latest"
docker image tag "$image_id" "$alias_ref"
if [ "$(docker image inspect --format '{{.Id}}' "$alias_ref")" != "$image_id" ]; then
  printf '%s\n' 'Website latest alias is not attached to the tested image ID.' >&2
  exit 1
fi
if alias_push_output=$(docker image push "$alias_ref" 2>&1); then
  printf '%s\n' "$alias_push_output"
else
  printf '%s\n' "$alias_push_output" >&2
  exit 1
fi
alias_digest=$(printf '%s\n' "$alias_push_output" | awk '$2 == "digest:" { print $3; exit }')
if [ "$alias_digest" != "$release_digest" ]; then
  printf 'Website latest digest %s differs from immutable release digest %s.\n' \
    "${alias_digest:-missing}" "$release_digest" >&2
  exit 1
fi

printf 'Published %s from tested image %s; latest shares the release digest.\n' "$release_ref" "$image_id"
