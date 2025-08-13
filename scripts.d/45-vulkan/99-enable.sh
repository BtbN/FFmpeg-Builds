#!/bin/bash

SCRIPT_SKIP="1"

ffbuild_enabled() {
    [[ $ADDINS_STR == *4.4* ]] && return -1
    return 0
}

ffbuild_dockerlayer() {
    to_df "COPY --link --from=${SELFLAYER} \$FFBUILD_PREFIX/. \$FFBUILD_PREFIX"
    to_df "COPY --link --from=${SELFLAYER} /opt/glslc /usr/bin/glslc"
}

ffbuild_dockerdl() {
    true
}

ffbuild_dockerbuild() {
    return 0
}
