#!/bin/bash
set -xe
cd "$(dirname "$0")"
source util/vars.sh

docker build --cache-from "$BASE_IMAGE" --tag "$BASE_IMAGE" images/base
docker build --build-arg GH_REPO="$REPO" --cache-from "$TARGET_IMAGE" --tag "$TARGET_IMAGE" "images/base-${TARGET}"

./generate.sh "$TARGET" "$VARIANT" "${ADDINS[@]}"

exec docker build --cache-from "$IMAGE" --tag "$IMAGE" .
