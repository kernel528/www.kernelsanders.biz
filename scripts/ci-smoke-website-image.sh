#!/usr/bin/env sh
set -eu

image_id=${1:?Usage: ci-smoke-website-image.sh <image-id> <alpine-release> <httpd-version> <site-version>}
expected_alpine=${2:?Usage: ci-smoke-website-image.sh <image-id> <alpine-release> <httpd-version> <site-version>}
expected_httpd=${3:?Usage: ci-smoke-website-image.sh <image-id> <alpine-release> <httpd-version> <site-version>}
expected_site=${4:?Usage: ci-smoke-website-image.sh <image-id> <alpine-release> <httpd-version> <site-version>}
container_id=""

cleanup() {
  rc=$?
  trap - EXIT
  if [ -n "$container_id" ]; then
    docker container rm --force "$container_id" >/dev/null || rc=1
  fi
  exit "$rc"
}
trap cleanup EXIT

actual_alpine=$(docker container run --rm --entrypoint cat "$image_id" /etc/alpine-release)
if [ "$actual_alpine" != "$expected_alpine" ]; then
  printf 'Alpine release mismatch: expected %s, got %s\n' "$expected_alpine" "$actual_alpine" >&2
  exit 1
fi

httpd_output=$(docker container run --rm --entrypoint httpd "$image_id" -v 2>&1)
case "$httpd_output" in
  *"Apache/$expected_httpd"*) ;;
  *) printf 'HTTPD version mismatch; expected Apache/%s, got:\n%s\n' "$expected_httpd" "$httpd_output" >&2; exit 1 ;;
esac

container_id=$(docker container create "$image_id")
docker container start "$container_id" >/dev/null
attempt=0
html=""
until html=$(docker container run --rm --network "container:$container_id" curlimages/curl:8.7.1 \
  --fail --silent --show-error http://localhost/ 2>/dev/null); do
  attempt=$((attempt + 1))
  if [ "$attempt" -ge 30 ]; then
    docker container logs "$container_id" >&2 || true
    printf '%s\n' 'Website image did not serve its homepage within 30 seconds.' >&2
    exit 1
  fi
  sleep 1
done

case "$html" in
  *"Site Version $expected_site"*) ;;
  *) printf 'Website homepage did not contain Site Version %s.\n' "$expected_site" >&2; exit 1 ;;
esac

printf 'Website smoke checks passed: Alpine %s, Apache %s, homepage version %s.\n' \
  "$actual_alpine" "$expected_httpd" "$expected_site"
