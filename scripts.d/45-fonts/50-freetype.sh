#!/bin/bash

SCRIPT_REPO="https://gitlab.freedesktop.org/freetype/freetype.git"
SCRIPT_COMMIT="fc9cc5038e05edceec3d0f605415540ac76163e9"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    run_autogen build_autotools

    add_pkgconfig_libs_private freetype2 harfbuzz
}

ffbuild_configure() {
    echo $(ffbuild_enable libfreetype)
}

ffbuild_unconfigure() {
    echo $(ffbuild_disable libfreetype)
}
