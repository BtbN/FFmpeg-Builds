#!/bin/bash

SCRIPT_REPO="https://github.com/meganz/mingw-std-threads.git"
SCRIPT_COMMIT="c931bac289dd431f1dd30fc4a5d1a7be36668073"

ffbuild_enabled() {
    [[ $TARGET == win* ]] || return -1
    return 0
}

ffbuild_dockerbuild() {
    mkdir -p "$FFBUILD_DESTPREFIX"/include
    cp *.h "$FFBUILD_DESTPREFIX"/include
}
