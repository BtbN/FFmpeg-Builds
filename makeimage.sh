#!/bin/bash
set -xe
cd "$(dirname "$0")"
source util/vars.sh

docker build --tag "$BASE_IMAGE" images/base
docker build --build-arg GH_REPO="$REPO" --tag "$TARGET_IMAGE" "images/base-${TARGET}"

./generate.sh "$TARGET" "$VARIANT" "${ADDINS[@]}"

exec docker build --tag "$IMAGE" .
