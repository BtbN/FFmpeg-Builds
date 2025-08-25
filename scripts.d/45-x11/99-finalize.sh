#!/bin/bash

SCRIPT_SKIP="1"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerlayer() {
    to_df "COPY --link --from=${SELFLAYER} \$FFBUILD_DESTPREFIX/. \$FFBUILD_PREFIX"
    to_df "COPY --link --from=${SELFLAYER} \$FFBUILD_DESTPREFIX/share/aclocal/. /usr/share/aclocal"
}

ffbuild_dockerdl() {
    return 0
}

ffbuild_dockerbuild() {
    rm "$FFBUILD_DESTPREFIX"/lib/lib*.so* || true
    rm "$FFBUILD_DESTPREFIX"/lib/*.la || true
}

ffbuild_libs() {
    echo -ldl
}
