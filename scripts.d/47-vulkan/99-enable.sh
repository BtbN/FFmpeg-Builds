#!/bin/bash

SCRIPT_SKIP="1"

ffbuild_enabled() {
    (( $(ffbuild_ffver) > 404 )) || return -1
    return 0
}

ffbuild_dockerlayer() {
    to_df "COPY --link --from=${SELFLAYER} \$FFBUILD_DESTPREFIX/. \$FFBUILD_PREFIX"
    to_df "COPY --link --from=${SELFLAYER} /opt/glslc /usr/bin/glslc"
}

ffbuild_dockerfinal() {
    to_df "COPY --link --from=${PREVLAYER} \$FFBUILD_PREFIX/. \$FFBUILD_PREFIX"
    to_df "COPY --link --from=${SELFLAYER} /opt/glslc /usr/bin/glslc"
}

ffbuild_dockerdl() {
    true
}

ffbuild_dockerbuild() {
    return 0
}
