#!/bin/bash

SCRIPT_REPO="https://github.com/libass/libass.git"
SCRIPT_COMMIT="534a5f8299c5ab3c2782856fcb843bfea47b7afc"

ffbuild_depends() {
    echo base
    echo fonts
    echo fribidi
    echo libiconv
}

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    run_autogen

    export CFLAGS="$CFLAGS -Dread_file=libass_internal_read_file"

    build_autotools
}

ffbuild_configure() {
    echo $(ffbuild_enable libass)
}

ffbuild_unconfigure() {
    echo $(ffbuild_disable libass)
}
