#!/bin/bash

AMF_REPO="https://github.com/GPUOpen-LibrariesAndSDKs/AMF.git"
AMF_COMMIT="802f92ee52b9efa77bf0d3ea8bfaed6040cdd35e"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /root/amf.sh"
    to_df "RUN bash -c 'source /root/amf.sh && ffbuild_dockerbuild && rm /root/amf.sh'"
}

ffbuild_dockerbuild() {
    git clone "$AMF_REPO" amf || return -1
    cd amf
    git checkout "$AMF_COMMIT" || return -1

    mkdir -p "$FFBUILD_PREFIX"/include
    mv amf/public/include "$FFBUILD_PREFIX"/include/AMF || return -1

    cd ..
    rm -rf amf
}

ffbuild_configure() {
    echo --enable-amf
}

ffbuild_unconfigure() {
    echo --disable-amf
}
