#!/bin/bash

SCRIPT_REPO="https://github.com/ultravideo/kvazaar.git"
SCRIPT_COMMIT="6040962bed5cc68c5ad01234c38c08b8b2822068"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    run_autogen
    build_autotools

    add_pkgconfig_cflags_private kvazaar "-DKVZ_STATIC_LIB"
    add_pkgconfig_libs_private kvazaar pthread
}

ffbuild_configure() {
    echo $(ffbuild_enable libkvazaar)
}

ffbuild_unconfigure() {
    echo $(ffbuild_disable libkvazaar)
}
