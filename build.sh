#!/bin/bash
set -xe

cd "$(dirname "$0")"

if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo "Invalid Arguments"
    exit -1
fi

TARGET="$1"
VARIANT="${2:-gpl}"
REPO="${GITHUB_REPOSITORY:-btbn/ffmpeg-builds}"
REPO="${REPO,,}"

IMAGE="$REPO/$TARGET-$VARIANT:latest"

get_output() {
    (
        SELF="$1"
        source $1
        ffbuild_enabled || exit 0
        ffbuild_$2 || exit -1
    )
}

CONFIGURE=""
CFLAGS=""
LDFLAGS=""

for script in scripts.d/*.sh; do
    CONFIGURE+="$(get_output $script configure)"
    CFLAGS+="$(get_output $script cflags)"
    LDFLAGS+="$(get_output $script ldflags)"
done

if [[ $VARIANT == gpl ]]; then
    VARIANT_FLAGS="--enable-gpl --enable-version3"
elif [[ $VARIANT == lgpl ]]; then
    VARIANT_FLAGS="--enable-version3"
else
    echo "Unknown variant"
    exit -1
fi

BUILD_CONTAINER="ffbuild"

docker rm "$BUILD_CONTAINER" 2>/dev/null || true
docker run -i --name "$BUILD_CONTAINER" "$IMAGE" bash -s <<EOF
    set -xe

    git clone https://git.videolan.org/git/ffmpeg.git ffmpeg
    cd ffmpeg
    
    ./configure \$FFBUILD_TARGET_FLAGS $VARIANT_FLAGS $CONFIGURE --extra-cflags="$CFLAGS" --extra-ldflags="$LDFLAGS"
    
    make -j\$(nproc)
EOF
