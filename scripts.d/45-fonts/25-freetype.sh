#!/bin/bash

SCRIPT_REPO="https://gitlab.freedesktop.org/freetype/freetype.git"
SCRIPT_COMMIT="fc9cc5038e05edceec3d0f605415540ac76163e9"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    run_autogen build_autotools --without-harfbuzz
}
