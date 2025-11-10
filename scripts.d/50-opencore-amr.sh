#!/bin/bash

SCRIPT_REPO="https://git.code.sf.net/p/opencore-amr/code"
SCRIPT_COMMIT="7dba8c32238418ce0b316a852b2224df586ca896"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    autoreconf -i

    build_autotools \
        --with-pic \
        --enable-amrnb-encoder \
        --enable-amrnb-decoder \
        --disable-examples
}

ffbuild_configure() {
    echo $(ffbuild_enable libopencore-amrnb) $(ffbuild_enable libopencore-amrwb)
}

ffbuild_unconfigure() {
    echo $(ffbuild_disable libopencore-amrnb) $(ffbuild_disable libopencore-amrwb)
}
