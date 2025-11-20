#!/bin/bash

SCRIPT_REPO="https://github.com/glennrp/libpng.git"
SCRIPT_COMMIT="1ebf432e85b53bf111a4585b410592727dd40a5a"

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
