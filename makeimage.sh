#!/bin/bash
set -xe
cd "$(dirname "$0")"
source util/vars.sh

if [[ -z "$QUICKBUILD" ]]; then
    if grep "FROM.*base.*" "images/base-${TARGET}/Dockerfile" >/dev/null 2>&1; then
        docker buildx --builder default build --load --tag "$BASE_IMAGE" images/base
    fi

    docker buildx --builder default build --load --build-arg GH_REPO="$REPO" --tag "$TARGET_IMAGE" "images/base-${TARGET}"
fi

./generate.sh "$TARGET" "$VARIANT" "${ADDINS[@]}"

docker buildx --builder default build --load --tag "$IMAGE" .
