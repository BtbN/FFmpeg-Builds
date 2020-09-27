#!/bin/bash

AOM_REPO="https://aomedia.googlesource.com/aom"
AOM_COMMIT="e53999055e9fc95d5cedeb582de7809464d69fe9"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    git-mini-clone "$AOM_REPO" "$AOM_COMMIT" aom
    cd aom

    mkdir cmbuild && cd cmbuild

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DBUILD_SHARED_LIBS=OFF -DCONFIG_TUNE_VMAF=1 .. || return -1
    make -j$(nproc) || return -1
    make install || return -1

    echo "Requires.private: libvmaf" >> "$FFBUILD_PREFIX/lib/pkgconfig/aom.pc"

    cd ../..
    rm -rf aom
}

ffbuild_configure() {
    echo --enable-libaom
}

ffbuild_unconfigure() {
    echo --disable-libaom
}
