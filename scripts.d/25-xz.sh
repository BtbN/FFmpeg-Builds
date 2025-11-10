#!/bin/bash

SCRIPT_REPO="https://github.com/tukaani-project/xz.git"
SCRIPT_COMMIT="8d26b72915e0d373f898b55935505857c30dbdb3"

ffbuild_depends() {
    echo base
    echo libiconv
}

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    ./autogen.sh --no-po4a --no-doxygen

    build_autotools --disable-symbol-versions --with-pic
}

ffbuild_configure() {
    echo $(ffbuild_enable lzma)
}

ffbuild_unconfigure() {
    echo $(ffbuild_disable lzma)
}
