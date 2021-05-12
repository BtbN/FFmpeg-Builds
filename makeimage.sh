#!/bin/bash
set -xe
cd "$(dirname "$0")"
source util/vars.sh

export DOCKER_BUILDKIT=1

if grep "FROM.*base.*" "images/base-${TARGET}/Dockerfile" >/dev/null 2>&1; then
    docker build --tag "$BASE_IMAGE" images/base
fi

docker build --build-arg GH_REPO="$REPO" --tag "$TARGET_IMAGE" "images/base-${TARGET}"

./generate.sh "$TARGET" "$VARIANT" "${ADDINS[@]}"

exec docker build --tag "$IMAGE" .
