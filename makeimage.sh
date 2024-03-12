#!/bin/bash
set -xeo pipefail
cd "$(dirname "$0")"
source util/vars.sh

TMPCFG="$(mktemp --suffix=.toml)"
cat <<EOF >"$TMPCFG"
[worker.oci]
  max-parallelism = 4
EOF
trap "rm -f '$TMPCFG'" EXIT

docker buildx inspect ffbuilder &>/dev/null || docker buildx create \
    --bootstrap \
    --name ffbuilder \
    --config "$TMPCFG" \
    --driver-opt network=host \
    --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=-1 \
    --driver-opt env.BUILDKIT_STEP_LOG_MAX_SPEED=-1

if [[ -z "$QUICKBUILD" ]]; then
    BASE_IMAGE_TARGET="${PWD}/.cache/images/base"
    if [[ ! -d "${BASE_IMAGE_TARGET}" ]]; then
        docker buildx --builder ffbuilder build \
            --cache-from=type=local,src=.cache/"${BASE_IMAGE/:/_}" \
            --cache-to=type=local,mode=max,dest=.cache/"${BASE_IMAGE/:/_}" \
            --load --tag "${BASE_IMAGE}" \
            "images/base"
        mkdir -p "${BASE_IMAGE_TARGET}"
        docker image save "${BASE_IMAGE}" | tar -x -C "${BASE_IMAGE_TARGET}"
    fi

    IMAGE_TARGET="${PWD}/.cache/images/base-${TARGET}"
    if [[ ! -d "${IMAGE_TARGET}" ]]; then
        docker buildx --builder ffbuilder build \
            --cache-from=type=local,src=.cache/"${TARGET_IMAGE/:/_}" \
            --cache-to=type=local,mode=max,dest=.cache/"${TARGET_IMAGE/:/_}" \
            --build-arg GH_REPO="${REGISTRY}/${REPO}" \
            --build-context "${BASE_IMAGE}=oci-layout://${BASE_IMAGE_TARGET}" \
            --load --tag "${TARGET_IMAGE}" \
            "images/base-${TARGET}"
        mkdir -p "${IMAGE_TARGET}"
        docker image save "${TARGET_IMAGE}" | tar -x -C "${IMAGE_TARGET}"
    fi

    CONTEXT_SRC="oci-layout://${IMAGE_TARGET}"
else
    CONTEXT_SRC="docker-image://${TARGET_IMAGE}"
fi

./download.sh
./generate.sh "$TARGET" "$VARIANT" "${ADDINS[@]}"

docker buildx --builder ffbuilder build \
    --cache-from=type=local,src=.cache/"${IMAGE/:/_}" \
    --cache-to=type=local,mode=max,dest=.cache/"${IMAGE/:/_}" \
    --build-context "${TARGET_IMAGE}=${CONTEXT_SRC}" \
    --load --tag "$IMAGE" .

if [[ -z "$NOCLEAN" ]]; then
    docker buildx rm -f ffbuilder
    rm -rf .cache/images
fi
