#!/bin/bash

RAV1E_SRC_PREFIX="https://github.com/xiph/rav1e/releases/download/p20200922"

ffbuild_enabled() {
    [[ $TARGET == win32 ]] && return -1
    [[ $VARIANT == *4.2* ]] && return -1
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    mkdir rav1e && cd rav1e

    if [[ $TARGET == win64 ]]; then
        wget -O rav1e.zip "${RAV1E_SRC_PREFIX}/rav1e-windows-gnu.zip"
    else
        echo "Unknown target"
        return -1
    fi

    unzip rav1e.zip
    cd rav1e-*

    rm -r bin lib/*.dll.a
    sed -i "s|^prefix=.*|prefix=${FFBUILD_PREFIX}|" lib/pkgconfig/rav1e.pc

    mkdir -p "$FFBUILD_PREFIX"/{include,lib/pkgconfig}
    cp -r include/. "$FFBUILD_PREFIX"/include/.
    cp -r lib/. "$FFBUILD_PREFIX"/lib/.

    cd ..
    rm -rf rav1e
}

ffbuild_configure() {
    echo --enable-librav1e
}

ffbuild_unconfigure() {
    [[ $VARIANT == *4.2* ]] && return 0
    echo --disable-librav1e
}
