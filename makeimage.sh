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
    --driver-opt network=host \
    --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=-1 \
    --driver-opt env.BUILDKIT_STEP_LOG_MAX_SPEED=-1

docker container inspect ffbuildreg &>/dev/null || \
    docker run --rm -d -p 127.0.0.1:64647:5000 --name ffbuildreg registry:2
LOCAL_REG_PORT="$(docker container inspect --format='{{range $p, $conf := .NetworkSettings.Ports}}{{(index $conf 0).HostPort}}{{end}}' ffbuildreg)"
LOCAL_ROOT="127.0.0.1:${LOCAL_REG_PORT}/local"

export REGISTRY_OVERRIDE_DL="127.0.0.1:${LOCAL_REG_PORT}" GITHUB_REPOSITORY_DL="local"

if [[ -z "$QUICKBUILD" ]]; then
    if grep "FROM.*base.*" "images/base-${TARGET}/Dockerfile" >/dev/null 2>&1; then
        docker buildx --builder ffbuilder build \
            --cache-from=type=local,src=.cache/"${BASE_IMAGE/:/_}" \
            --cache-to=type=local,mode=max,dest=.cache/"${BASE_IMAGE/:/_}" \
            --push --tag "${LOCAL_ROOT}/base:latest" images/base
    fi

    docker buildx --builder ffbuilder build \
        --cache-from=type=local,src=.cache/"${TARGET_IMAGE/:/_}" \
        --cache-to=type=local,mode=max,dest=.cache/"${TARGET_IMAGE/:/_}" \
        --push --tag "${LOCAL_ROOT}/base-${TARGET}:latest" \
        --build-arg GH_REPO="$LOCAL_ROOT" "images/base-${TARGET}"

    export REGISTRY_OVERRIDE="$REGISTRY_OVERRIDE_DL" GITHUB_REPOSITORY="$GITHUB_REPOSITORY_DL"
fi

./generate.sh "$TARGET" "$VARIANT" "${ADDINS[@]}"

docker buildx --builder ffbuilder build -f Dockerfile.dl \
    --cache-from=type=local,src=.cache/"${DL_IMAGE/:/_}" \
    --cache-to=type=local,mode=max,dest=.cache/"${DL_IMAGE/:/_}" \
    --push --tag "${LOCAL_ROOT}/dl_cache:latest" .

docker buildx --builder ffbuilder build \
    --cache-from=type=local,src=.cache/"${IMAGE/:/_}" \
    --cache-to=type=local,mode=max,dest=.cache/"${IMAGE/:/_}" \
    --load --tag "$IMAGE" .

docker container stop ffbuildreg
docker buildx rm -f ffbuilder
