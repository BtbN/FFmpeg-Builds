#!/bin/bash

SCRIPT_REPO="https://github.com/GPUOpen-LibrariesAndSDKs/AMF.git"
SCRIPT_COMMIT="57ee0cfb0e1a08d9041f77435653794c1b012be0"

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
