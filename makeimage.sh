#!/bin/bash
set -xeo pipefail
cd "$(dirname "$0")"
source util/vars.sh

docker buildx inspect ffbuilder &>/dev/null || docker buildx create \
    --bootstrap \
    --name ffbuilder \
    --buildkitd-flags "--oci-max-parallelism=4" \
    --driver-opt network=host \
    --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=-1 \
    --driver-opt env.BUILDKIT_STEP_LOG_MAX_SPEED=-1

if [[ -z "$NOCLEAN" ]]; then
    trap 'rc=$?; [[ $rc -eq 0 ]] && docker buildx rm -f ffbuilder; exit $rc' EXIT
fi

GH_REPO="${REGISTRY}/${REPO}"
BAKE_TARGETS=( image )

if [[ -z "$QUICKBUILD" ]]; then
    BAKE_TARGETS+=( target-base )
fi

to_bake() {
    printf "$@"
    echo
}

bake_images() {
    local -; set +x
    {
        if [[ -z "$QUICKBUILD" ]]; then
            to_bake 'target "base" {'
            to_bake '  context    = "images/base"'
            to_bake '  tags       = ["%s"]' "$BASE_IMAGE"
            to_bake '  output     = ["type=docker"]'
            to_bake '  cache-from = ["type=local,src=.cache/%s"]' "${BASE_IMAGE/:/_}"
            to_bake '  cache-to   = ["type=local,mode=max,dest=.cache/%s"]' "${BASE_IMAGE/:/_}"
            to_bake '}'

            to_bake 'target "target-base" {'
            to_bake '  context    = "images/base-%s"' "$TARGET"
            to_bake '  args       = { GH_REPO = "%s" }' "$GH_REPO"
            to_bake '  contexts   = { "%s/base" = "target:base" }' "$GH_REPO"
            to_bake '  tags       = ["%s"]' "$TARGET_IMAGE"
            to_bake '  output     = ["type=docker"]'
            to_bake '  cache-from = ["type=local,src=.cache/%s"]' "${TARGET_IMAGE/:/_}"
            to_bake '  cache-to   = ["type=local,mode=max,dest=.cache/%s"]' "${TARGET_IMAGE/:/_}"
            to_bake '}'
        fi

        to_bake 'target "image" {'
        to_bake '  context    = "."'
        if [[ -z "$QUICKBUILD" ]]; then
            to_bake '  contexts   = { "%s/base-%s" = "target:target-base" }' "$GH_REPO" "$TARGET"
        fi
        to_bake '  tags       = ["%s"]' "$IMAGE"
        to_bake '  output     = ["type=docker"]'
        to_bake '  cache-from = ["type=local,src=.cache/%s"]' "${IMAGE/:/_}"
        to_bake '  cache-to   = ["type=local,mode=max,dest=.cache/%s"]' "${IMAGE/:/_}"
        to_bake '}'
    } | tee /dev/stderr | docker buildx --builder ffbuilder bake -f - "$@"
}

if [[ -z "$QUICKBUILD" ]]; then
    bake_images base
fi

./download.sh
./generate.sh "$TARGET" "$VARIANT" "${ADDINS[@]}"

bake_images "${BAKE_TARGETS[@]}"
