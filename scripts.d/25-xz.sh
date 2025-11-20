#!/bin/bash

SCRIPT_REPO="https://github.com/tukaani-project/xz.git"
SCRIPT_COMMIT="f57b1716cd0853474980c90a892204dee9bdea1a"

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
