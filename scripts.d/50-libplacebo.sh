#!/bin/bash

SCRIPT_REPO="https://code.videolan.org/videolan/libplacebo.git"
SCRIPT_COMMIT="2e5a392b7f1e4c25d5a3f931e253d71ab566757f"

ffbuild_depends() {
    echo base
    echo vulkan
}

ffbuild_enabled() {
    (( $(ffbuild_ffver) > 600 )) || return -1
    return 0
}

ffbuild_dockerdl() {
    default_dl .
    echo "git submodule update --init --recursive --depth=1 --filter=blob:none"
}

ffbuild_dockerbuild() {
    sed -i 's/DPL_EXPORT/DPL_STATIC/' src/meson.build

    local extra_opts=(
        -Dvulkan=enabled
        -Dvk-proc-addr=disabled
        -Dvulkan-registry="$FFBUILD_PREFIX"/share/vulkan/registry/vk.xml
        -Dshaderc=enabled
        -Dglslang=disabled
        -Ddemos=false
        -Dtests=false
        -Dbench=false
        -Dfuzz=false
    )

    if [[ $TARGET == win* ]]; then
        extra_opts+=(-Dd3d11=enabled)
    fi

    build_meson "${extra_opts[@]}"

    add_pkgconfig_libs_private libplacebo stdc++
}

ffbuild_configure() {
    echo --enable-libplacebo
}

ffbuild_unconfigure() {
    [[ $ADDINS_STR == *4.4* ]] && return 0
    echo --disable-libplacebo
}
