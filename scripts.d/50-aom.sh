#!/bin/bash

SCRIPT_REPO="https://aomedia.googlesource.com/aom"
SCRIPT_COMMIT="d954a78fdae80b49229cb7c4b7032f5c0e67b0e8"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "RUN --mount=src=${SELF},dst=/stage.sh --mount=src=patches/aom,dst=/patches run_stage /stage.sh"
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" aom
    cd aom

    for patch in /patches/*.patch; do
        echo "Applying $patch"
        git am < "$patch"
    done

    mkdir cmbuild && cd cmbuild

    # Workaround broken build system
    export CFLAGS="$CFLAGS -pthread -I/opt/ffbuild/include/libvmaf"

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DBUILD_SHARED_LIBS=OFF -DENABLE_EXAMPLES=NO -DENABLE_TESTS=NO -DENABLE_TOOLS=NO -DCONFIG_TUNE_VMAF=1 ..
    make -j$(nproc)
    make install

    echo "Requires.private: libvmaf" >> "$FFBUILD_PREFIX/lib/pkgconfig/aom.pc"
}

ffbuild_configure() {
    echo --enable-libaom
}

ffbuild_unconfigure() {
    echo --disable-libaom
}
