#!/bin/bash

SCRIPT_REPO="https://github.com/mm2/Little-CMS.git"
SCRIPT_COMMIT="8888d842a7556a0aac093808f10d49c4141c354a"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    export CFLAGS="$CFLAGS -fpermissive"

    build_meson -Dutils=false -Dfastfloat=true -Dthreaded=true
}
