#!/bin/bash

SCRIPT_SKIP="1"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerdl() {
    return 0
}

ffbuild_dockerbuild() {
    if [[ $TARGET == linux* ]]; then
        rm "$FFBUILD_PREFIX"/lib/lib*.so* || true
        rm "$FFBUILD_PREFIX"/lib/*.la || true
    fi
}
