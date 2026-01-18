#!/bin/sh
set -e

version_line=$(awk '/^\* /{version=$2} END{print version}' "$1")
if [ -z "$version_line" ]; then
    echo "No version found in $1" >&2
    exit 1
fi

target_file="$2"
sed -i "s/style.css?v=[0-9.][0-9.]*/style.css?v=$version_line/" "$target_file"
sed -i "s/Site Version [0-9.][0-9.]*/Site Version $version_line/g" "$target_file"
sed -i "s|/releases/tag/[0-9.][0-9.]*|/releases/tag/$version_line|g" "$target_file"
