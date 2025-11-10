#!/bin/bash

SCRIPT_REPO="https://svn.code.sf.net/p/lame/svn/trunk/lame"
SCRIPT_REV="6531"

ffbuild_depends() {
    echo base
    echo libiconv
}

ffbuild_enabled() {
    return 0
}

ffbuild_dockerdl() {
    echo "retry-tool sh -c \"rm -rf lame && svn checkout '${SCRIPT_REPO}@${SCRIPT_REV}' lame\" && cd lame"
}

ffbuild_dockerbuild() {
    autoreconf -i

    export CFLAGS="$CFLAGS -DNDEBUG -Wno-error=incompatible-pointer-types"

    build_autotools \
        --enable-nasm \
        --disable-gtktest \
        --disable-cpml \
        --disable-frontend \
        --disable-decoder
}

ffbuild_configure() {
    echo $(ffbuild_enable libmp3lame)
}

ffbuild_unconfigure() {
    echo $(ffbuild_disable libmp3lame)
}
