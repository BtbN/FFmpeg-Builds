#!/bin/bash

SCRIPT_REPO="https://github.com/mm2/Little-CMS.git"
SCRIPT_COMMIT="5cdf3044d290e556beddc197b350aa88cc9bf00f"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    export CFLAGS="$CFLAGS -fpermissive"

    build_meson -Dutils=false -Dfastfloat=true -Dthreaded=true
}
