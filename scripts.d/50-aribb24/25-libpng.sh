#!/bin/bash

SCRIPT_REPO="https://github.com/glennrp/libpng.git"
SCRIPT_COMMIT="ddce3ff853522a6e709a29d71487c5fb06cd9b65"

ffbuild_depends() {
    echo base
    echo zlib
}

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    export CPPFLAGS="$CPPFLAGS -I$FFBUILD_PREFIX/include"

    run_autogen build_autotools --with-pic
}
