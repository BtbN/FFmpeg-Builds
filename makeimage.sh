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

hash_stage() {
    { find "$1" -type f -exec sha256sum {} + ; printf '%s\n' "$@"; } | sha256sum | cut -d" " -f1
}

prune_cache() {
    [[ -d "$1" ]] || return 0
    find "$1" -mindepth 1 -maxdepth 1 ! -name "$2" -exec rm -rf {} +
}

if [[ -z "$QUICKBUILD" ]]; then
    BASE_HASH="$(hash_stage images/base)"
    BASE_IMAGE_TARGET="${PWD}/.cache/images/base/${BASE_HASH}"
    prune_cache .cache/images/base "${BASE_HASH}"
    if [[ ! -d "${BASE_IMAGE_TARGET}" ]]; then
        docker buildx --builder ffbuilder build \
            --cache-from=type=local,src=.cache/"${BASE_IMAGE/:/_}" \
            --cache-to=type=local,mode=max,dest=.cache/"${BASE_IMAGE/:/_}" \
            --load --tag "${BASE_IMAGE}" \
            "images/base"
        mkdir -p "${BASE_IMAGE_TARGET}"
        docker image save "${BASE_IMAGE}" | tar -x -C "${BASE_IMAGE_TARGET}"
    fi

    TARGET_HASH="$(hash_stage "images/base-${TARGET}" "${BASE_HASH}" "${REGISTRY}/${REPO}")"
    IMAGE_TARGET="${PWD}/.cache/images/base-${TARGET}/${TARGET_HASH}"
    prune_cache .cache/images/base-"${TARGET}" "${TARGET_HASH}"
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
