#!/bin/bash

SCRIPT_REPO="https://github.com/GPUOpen-LibrariesAndSDKs/AMF.git"
SCRIPT_COMMIT="afed28d37aca1938da2eedc50599bb3535a987ec"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerdl() {
    default_dl .
    echo "rm -rf .git Thirdparty"
}

ffbuild_dockerbuild() {
    mkdir -p "$FFBUILD_DESTPREFIX"/include
    mv amf/public/include "$FFBUILD_DESTPREFIX"/include/AMF
}

ffbuild_configure() {
    echo --enable-amf
}

ffbuild_unconfigure() {
    echo --disable-amf
}
