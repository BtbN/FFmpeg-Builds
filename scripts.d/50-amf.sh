#!/bin/bash

AMF_REPO="https://github.com/GPUOpen-LibrariesAndSDKs/AMF.git"
AMF_COMMIT="c7f58ee7853a3736670873e068180f6d83a81c7b"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$AMF_REPO" "$AMF_COMMIT" amf
    cd amf

    mkdir -p "$FFBUILD_PREFIX"/include
    mv amf/public/include "$FFBUILD_PREFIX"/include/AMF
}

ffbuild_configure() {
    echo --enable-amf
}

ffbuild_unconfigure() {
    echo --disable-amf
}
