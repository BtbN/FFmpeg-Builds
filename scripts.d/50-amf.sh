#!/bin/bash

SCRIPT_REPO="https://github.com/GPUOpen-LibrariesAndSDKs/AMF.git"
SCRIPT_COMMIT="9c7189ebb0a78e7e9287547b7898995abf268af8"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" amf
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
