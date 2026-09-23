#!/bin/bash

SCRIPT_REPO="https://github.com/GNOME/librsvg.git"
SCRIPT_COMMIT="7612431eb02dc009319094f8513d63c1faaecfb4"

ffbuild_depends() {
    echo base
    echo libxml2
    echo dav1d
    echo fonts
}

ffbuild_enabled() {
    (( $(ffbuild_ffver) >= 404 )) || return -1
    return 0
}

ffbuild_dockerdl() {
    default_dl .
    echo 'mkdir .cargo && CARGO_HOME="$(mktemp -d)" cargo vendor --versioned-dirs > .cargo/config.toml'
}

ffbuild_dockerbuild() {
    export CARGO_NET_OFFLINE=true

    sed -i -e "/'PKG_CONFIG_ALL_STATIC'/d" -e "/'SYSTEM_DEPS_LINK'/d" meson.build

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=static
        --wrap-mode=nodownload
        -Dtriplet="$FFBUILD_RUST_TARGET"
        -Db_lto=false
        -Davif=enabled
        -Dpixbuf=disabled
        -Dpixbuf-loader=disabled
        -Drsvg-convert=disabled
        -Dintrospection=disabled
        -Dvala=disabled
        -Ddocs=disabled
        -Dtests=false
    )

    if [[ $TARGET == win* || $TARGET == linux* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return -1
    fi

    meson setup "${myconf[@]}" ..
    ninja -j$(nproc)
    DESTDIR="$FFBUILD_DESTDIR" ninja install
}

ffbuild_configure() {
    echo --enable-librsvg
}

ffbuild_unconfigure() {
    echo --disable-librsvg
}
