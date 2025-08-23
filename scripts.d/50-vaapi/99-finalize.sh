#!/bin/bash

SCRIPT_SKIP="1"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerdl() {
    true
}

ffbuild_dockerbuild() {
    if [[ $TARGET == linux* ]]; then
        rm "$FFBUILD_DESTPREFIX"/lib/lib*.so* || true
        rm "$FFBUILD_DESTPREFIX"/lib/*.la || true
    fi
}
