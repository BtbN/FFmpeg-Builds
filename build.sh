#!/bin/bash
set -xe
cd "$(dirname "$0")"
source util/vars.sh

get_output() {
    (
        SELF="$1"
        source $1
        if ffbuild_enabled; then
            ffbuild_$2 || exit 0
        else
            ffbuild_un$2 || exit 0
        fi
    )
}

source "variants/${VARIANT}.sh"
source "variants/${TARGET}-${VARIANT}.sh"

for script in scripts.d/*.sh; do
    FF_CONFIGURE+=" $(get_output $script configure)"
    FF_CFLAGS+=" $(get_output $script cflags)"
    FF_CXXFLAGS+=" $(get_output $script cxxflags)"
    FF_LDFLAGS+=" $(get_output $script ldflags)"
done

FF_CONFIGURE="$(xargs <<< "$FF_CONFIGURE")"
FF_CFLAGS="$(xargs <<< "$FF_CFLAGS")"
FF_CXXFLAGS="$(xargs <<< "$FF_CXXFLAGS")"
FF_LDFLAGS="$(xargs <<< "$FF_LDFLAGS")"

rm -rf ffbuild
mkdir ffbuild

docker run --rm -i -u "$(id -u):$(id -g)" -v $PWD/ffbuild:/ffbuild "$IMAGE" bash -s <<EOF
    set -xe
    cd /ffbuild
    rm -rf ffmpeg prefix

    git clone https://git.videolan.org/git/ffmpeg.git ffmpeg
    cd ffmpeg
    git checkout $GIT_BRANCH

    ./configure --prefix=/ffbuild/prefix --pkg-config-flags="--static" \$FFBUILD_TARGET_FLAGS $FF_CONFIGURE --extra-cflags="$FF_CFLAGS" --extra-cxxflags="$FF_CXXFLAGS" --extra-ldflags="$FF_LDFLAGS"
    make -j\$(nproc)
    make install    
EOF

mkdir -p artifacts
ARTIFACTS_PATH="$PWD/artifacts"
BUILD_NAME="ffmpeg-$(./ffbuild/ffmpeg/ffbuild/version.sh ffbuild/ffmpeg)-${TARGET}-${VARIANT}"

mkdir -p "ffbuild/pkgroot/$BUILD_NAME"
package_variant ffbuild/prefix "ffbuild/pkgroot/$BUILD_NAME"

cd ffbuild/pkgroot
zip -9 -r "${ARTIFACTS_PATH}/${BUILD_NAME}.zip" "$BUILD_NAME"
cd -

rm -rf ffbuild
