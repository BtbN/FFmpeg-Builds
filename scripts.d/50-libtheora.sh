#!/bin/bash

SCRIPT_REPO="https://github.com/xiph/theora.git"
SCRIPT_COMMIT="23161c4a63fd9f9d09b9e972f95def2d56c777af"

ffbuild_depends() {
    echo base
    echo libogg
}

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    local extra_opts=(
        --with-pic
        --disable-examples
        --disable-oggtest
        --disable-vorbistest
        --disable-spec
        --disable-doc
    )

    if [[ $TARGET == win64 ]]; then
        extra_opts+=(--disable-asm)
    fi

    run_autogen build_autotools "${extra_opts[@]}"
}

ffbuild_configure() {
    echo $(ffbuild_enable libtheora)
}

ffbuild_unconfigure() {
    echo $(ffbuild_disable libtheora)
}
