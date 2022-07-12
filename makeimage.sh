#!/bin/bash
set -xe
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
    --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=-1 \
    --driver-opt env.BUILDKIT_STEP_LOG_MAX_SPEED=-1

if [[ -z "$QUICKBUILD" ]]; then
    if grep "FROM.*base.*" "images/base-${TARGET}/Dockerfile" >/dev/null 2>&1; then
        docker buildx --builder ffbuilder build \
            --cache-from=type=local,src=.cache/"${BASE_IMAGE/:/_}" \
            --cache-to=type=local,mode=max,dest=.cache/"${BASE_IMAGE/:/_}" \
            --load --tag "$BASE_IMAGE" images/base
    fi

    docker buildx --builder ffbuilder build \
        --cache-from=type=local,src=.cache/"${TARGET_IMAGE/:/_}" \
        --cache-to=type=local,mode=max,dest=.cache/"${TARGET_IMAGE/:/_}" \
        --load --build-arg GH_REPO="$REPO" --tag "$TARGET_IMAGE" "images/base-${TARGET}"
fi

./generate.sh "$TARGET" "$VARIANT" "${ADDINS[@]}"

docker buildx --builder ffbuilder build \
    --cache-from=type=local,src=.cache/"${IMAGE/:/_}" \
    --cache-to=type=local,mode=max,dest=.cache/"${IMAGE/:/_}" \
    --load --tag "$IMAGE" .

docker buildx rm -f ffbuilder
