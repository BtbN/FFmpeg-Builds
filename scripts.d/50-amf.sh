#!/bin/bash

AMF_REPO="https://github.com/GPUOpen-LibrariesAndSDKs/AMF.git"
AMF_COMMIT="9c36583841b01c23b3972005ff6db6fd4aaac1a0"

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
