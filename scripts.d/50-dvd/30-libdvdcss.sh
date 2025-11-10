#!/bin/bash

SCRIPT_REPO="https://code.videolan.org/videolan/libdvdcss.git"
SCRIPT_COMMIT="c838ca97553aeb8505b7baf02b9a90f8505de212"

ffbuild_enabled() {
    [[ $VARIANT == lgpl* ]] && return -1
    [[ $ADDINS_STR == *4.4* ]] && return -1
    [[ $ADDINS_STR == *5.0* ]] && return -1
    [[ $ADDINS_STR == *5.1* ]] && return -1
    [[ $ADDINS_STR == *6.0* ]] && return -1
    [[ $ADDINS_STR == *6.1* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    # stop the static library from exporting symbols when linked into a shared lib
    sed -i 's/SUPPORT_ATTRIBUTE_VISIBILITY_DEFAULT/SUPPORT_ATTRIBUTE_VISIBILITY_DEFAULT_DISABLED/g' meson.build
    sed -i 's/-DLIBDVDCSS_EXPORTS/-DLIBDVDCSS_EXPORTS_DISABLED/g' src/meson.build

    export CFLAGS="$CFLAGS -Dprint_error=dvdcss_print_error -Dprint_debug=dvdcss_print_debug"

    build_meson -Denable_docs=false -Denable_examples=false
}
