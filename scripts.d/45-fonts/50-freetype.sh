#!/bin/bash

SCRIPT_REPO="https://gitlab.freedesktop.org/freetype/freetype.git"
SCRIPT_COMMIT="f238830d77d7a42427e5fc9401e2955259afc652"

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
