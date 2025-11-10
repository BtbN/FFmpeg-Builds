#!/bin/bash

SCRIPT_REPO="https://gitlab.freedesktop.org/freetype/freetype.git"
SCRIPT_COMMIT="f238830d77d7a42427e5fc9401e2955259afc652"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    run_autogen build_autotools --without-harfbuzz
}
