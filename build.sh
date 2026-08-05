#!/bin/bash
set -xe
shopt -s globstar
cd "$(dirname "$0")"
source util/vars.sh

source "variants/${TARGET}-${VARIANT}.sh"

for addin in ${ADDINS[*]}; do
    source "addins/${addin}.sh"
done

if docker info -f "{{println .SecurityOptions}}" | grep rootless >/dev/null 2>&1; then
    UIDARGS=()
else
    UIDARGS=( -u "$(id -u):$(id -g)" )
fi

rm -rf ffbuild
mkdir ffbuild

FFMPEG_REPO="${FFMPEG_REPO:-https://github.com/FFmpeg/FFmpeg.git}"
FFMPEG_REPO="${FFMPEG_REPO_OVERRIDE:-$FFMPEG_REPO}"
GIT_BRANCH="${GIT_BRANCH:-master}"
GIT_BRANCH="${GIT_BRANCH_OVERRIDE:-$GIT_BRANCH}"

BUILD_SCRIPT="$(mktemp)"
trap "rm -f -- '$BUILD_SCRIPT'" EXIT

cat <<'EOF' >"$BUILD_SCRIPT"
    set -xe
    cd /ffbuild
    rm -rf ffmpeg prefix
EOF

# Append the $ORIGIN rpath flags here rather than in scripts.d/99-rpath.sh, so
# the value never has to survive xargs, printf and Dockerfile ENV parsing.
#
# Both quotings below are needed:
#   - the heredoc delimiter is quoted, so the host expands nothing
#   - the appended fragment is single-quoted and *concatenated*, so the
#     container's shell performs no substitution on it either
# Do not switch this to "${FF_LDEXEFLAGS//@PLACEHOLDER@/$var}" -- bash's pattern
# substitution eats a backslash from the replacement on some bash versions but
# not others, which silently costs one escaping level.
#
# configure must receive exactly  -Wl,-rpath=\\\$\$ORIGIN  because from there:
#   configure's append() eval  \\\$\$ORIGIN -> \$$ORIGIN  (into config.mak)
#   make expanding config.mak  \$$ORIGIN    -> \$ORIGIN
#   the shell running the link \$ORIGIN     -> $ORIGIN
if [[ $TARGET == linux* && $VARIANT == *shared* ]]; then
cat <<'EOF' >>"$BUILD_SCRIPT"
    FF_LDEXEFLAGS="$FF_LDEXEFLAGS "'-Wl,-rpath=\\\$\$ORIGIN -Wl,-rpath=\\\$\$ORIGIN/../lib'
EOF
fi

cat <<EOF >>"$BUILD_SCRIPT"
    git clone --filter=blob:none --branch='$GIT_BRANCH' '$FFMPEG_REPO' ffmpeg
    cd ffmpeg

    ./configure --prefix=/ffbuild/prefix --pkg-config-flags="--static" \$FFBUILD_TARGET_FLAGS \$FF_CONFIGURE \
        --extra-cflags="\$FF_CFLAGS" --extra-cxxflags="\$FF_CXXFLAGS" --extra-libs="\$FF_LIBS" \
        --extra-ldflags="\$FF_LDFLAGS" --extra-ldexeflags="\$FF_LDEXEFLAGS" \
        --cc="\$CC" --cxx="\$CXX" --ar="\$AR" --ranlib="\$RANLIB" --nm="\$NM" \
        --extra-version="\$(date +%Y%m%d)" || { cat ffbuild/config.log; exit 1; }
    make -j\$(nproc) V=1
    make install install-doc
EOF

# A broken $ORIGIN rpath still builds and still runs anywhere ld.so.cache
# happens to know the libs, so it fails silently - so check and assert.
if [[ $TARGET == linux* && $VARIANT == *shared* ]]; then
cat <<'EOF' >>"$BUILD_SCRIPT"
    readelf -d /ffbuild/prefix/bin/ffmpeg | grep -q ORIGIN || {
        echo "ERROR: ffmpeg was linked without an \$ORIGIN rpath." >&2
        echo "       See the FF_LDEXEFLAGS rpath append earlier in build.sh." >&2
        readelf -d /ffbuild/prefix/bin/ffmpeg | grep -i rpath >&2
        exit 1
    }
EOF
fi

[[ -t 1 ]] && TTY_ARG="-t" || TTY_ARG=""

docker run --rm -i $TTY_ARG "${UIDARGS[@]}" -v "$PWD/ffbuild":/ffbuild -v "$BUILD_SCRIPT":/build.sh "$IMAGE" bash /build.sh

if [[ -n "$FFBUILD_OUTPUT_DIR" ]]; then
    mkdir -p "$FFBUILD_OUTPUT_DIR"
    package_variant ffbuild/prefix "$FFBUILD_OUTPUT_DIR"
    [[ -n "$LICENSE_FILE" ]] && cp "ffbuild/ffmpeg/$LICENSE_FILE" "$FFBUILD_OUTPUT_DIR/LICENSE.txt"
    rm -rf ffbuild
    exit 0
fi

mkdir -p artifacts
ARTIFACTS_PATH="$PWD/artifacts"
BUILD_NAME="ffmpeg-$(./ffbuild/ffmpeg/ffbuild/version.sh ffbuild/ffmpeg)-${TARGET}-${VARIANT}${ADDINS_STR:+-}${ADDINS_STR}"

mkdir -p "ffbuild/pkgroot/$BUILD_NAME"
package_variant ffbuild/prefix "ffbuild/pkgroot/$BUILD_NAME"

[[ -n "$LICENSE_FILE" ]] && cp "ffbuild/ffmpeg/$LICENSE_FILE" "ffbuild/pkgroot/$BUILD_NAME/LICENSE.txt"

cd ffbuild/pkgroot
if [[ "${TARGET}" == win* ]]; then
    OUTPUT_FNAME="${BUILD_NAME}.zip"
    docker run --rm -i $TTY_ARG "${UIDARGS[@]}" -v "${ARTIFACTS_PATH}":/out -v "${PWD}/${BUILD_NAME}":"/${BUILD_NAME}" -w / "$IMAGE" zip -9 -r "/out/${OUTPUT_FNAME}" "$BUILD_NAME"
else
    OUTPUT_FNAME="${BUILD_NAME}.tar.xz"
    docker run --rm -i $TTY_ARG "${UIDARGS[@]}" -v "${ARTIFACTS_PATH}":/out -v "${PWD}/${BUILD_NAME}":"/${BUILD_NAME}" -w / "$IMAGE" tar -I "xz -T0" -cf "/out/${OUTPUT_FNAME}" "$BUILD_NAME"
fi
cd -

rm -rf ffbuild

if [[ -n "$GITHUB_ACTIONS" ]]; then
    echo "build_name=${BUILD_NAME}" >> "$GITHUB_OUTPUT"
    echo "${OUTPUT_FNAME}" > "${ARTIFACTS_PATH}/${TARGET}-${VARIANT}${ADDINS_STR:+-}${ADDINS_STR}.txt"
fi
