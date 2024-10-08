#!/bin/bash

SCRIPT_SKIP="1"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerlayer() {
    to_df "COPY --link --from=${SELFLAYER} \$FFBUILD_PREFIX/. \$FFBUILD_PREFIX"
    to_df "COPY --link --from=${SELFLAYER} \$FFBUILD_PREFIX/share/aclocal/. /usr/share/aclocal"
}

ffbuild_dockerdl() {
    return 0
}

ffbuild_dockerbuild() {
    rm "$FFBUILD_PREFIX"/lib/lib*.so* || true
    rm "$FFBUILD_PREFIX"/lib/*.la || true
}

ffbuild_libs() {
    echo -ldl
}
