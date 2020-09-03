#!/bin/bash
set -xe
cd "$(dirname "$0")"
source util/vars.sh

get_output() {
    (
        SELF="$1"
        source $1
        ffbuild_enabled || exit 0
        ffbuild_$2 || exit 0
    )
}

source "variants/${VARIANT}.sh"
source "variants/${TARGET}-${VARIANT}.sh"

for script in scripts.d/*.sh; do
    CONFIGURE+=" $(get_output $script configure)"
    CFLAGS+=" $(get_output $script cflags)"
    LDFLAGS+=" $(get_output $script ldflags)"
done

rm -rf ffbuild
mkdir ffbuild

docker run --rm -i -u "$(id -u):$(id -g)" -v $PWD/ffbuild:/ffbuild "$IMAGE" bash -s <<EOF
    set -xe
    cd /ffbuild
    rm -rf ffmpeg prefix

    git clone https://git.videolan.org/git/ffmpeg.git ffmpeg
    cd ffmpeg
    git checkout $GIT_BRANCH

    ./configure --prefix=/ffbuild/prefix --pkg-config-flags="--static" \$FFBUILD_TARGET_FLAGS $CONFIGURE --extra-cflags="$CFLAGS" --extra-ldflags="$LDFLAGS"
    make -j\$(nproc)
    make install    
EOF

mkdir ffbuild/pkgroot
package_variant ffbuild/prefix ffbuild/pkgroot

mkdir -p artifacts
ARTIFACTS_PATH="$PWD/artifacts"
BUILD_NAME="ffmpeg-$(git --git-dir=ffbuild/ffmpeg/.git describe)-${TARGET}-${VARIANT}"

cd ffbuild/pkgroot
zip -9 -r "${ARTIFACTS_PATH}/${BUILD_NAME}.zip" ./*
cd -

rm -rf ffbuild
