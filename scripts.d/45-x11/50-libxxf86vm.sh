#!/bin/bash

LIBXXF86VM_REPO="https://gitlab.freedesktop.org/xorg/lib/libxxf86vm.git"
LIBXXF86VM_COMMIT="7f43cd2a905e7b93b83c9ce81dabb768f6fa2bc7"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    [[ $TARGET == linuxarm64 ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBXXF86VM_REPO" "$LIBXXF86VM_COMMIT" libxxf86vm
    cd libxxf86vm

    autoreconf -i

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --enable-shared
        --disable-static
        --with-pic
    )

    if [[ $TARGET == linux* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    export CFLAGS="$RAW_CFLAGS"
    export LDFLAFS="$RAW_LDFLAGS"

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install

    gen-implib "$FFBUILD_PREFIX"/lib/{libXxf86vm.so.1,libXxf86vm.a}
    rm "$FFBUILD_PREFIX"/lib/libXxf86vm{.so*,.la}
}
