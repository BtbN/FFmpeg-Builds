#!/bin/bash

SCRIPT_REPO="https://github.com/libass/libass.git"
SCRIPT_COMMIT="e60dddb7db62cc009175843bdb0b0dfedceebedb"

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
