#!/bin/bash

SCRIPT_REPO="https://github.com/GNOME/glib.git"
SCRIPT_COMMIT="6f98b0b8ad9cb7f9be237b4a0dba3833331a8f37"

ffbuild_depends() {
    echo base
    echo zlib
    echo libiconv
    echo pcre2
    echo libffi
}

ffbuild_enabled() {
    return 0
}

ffbuild_dockerdl() {
    default_dl .
    echo "git submodule update --init --recursive --depth=1"
    echo "meson subprojects download proxy-libintl"
}

ffbuild_dockerbuild() {
    # Skip auto-initialization of GIO appinfo. It's relatively expensive and automatically done on demand when needed.
    sed -zi 's/[^\n]*gio_win32_appinfo_init[^\n]*\n//g; t; q1' gio/giomodule.c

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=static
        --wrap-mode=nodownload
        -Dtests=false
        -Dinstalled_tests=false
        -Dglib_debug=disabled
        -Dnls=disabled
        -Dintrospection=disabled
        -Ddocumentation=false
        -Dman-pages=disabled
        -Dsysprof=disabled
        -Dlibelf=disabled
        -Dmultiarch=false
        -Dbsymbolic_functions=false
        -Dselinux=disabled
        -Dlibmount=disabled
        -Ddtrace=disabled
        -Dsystemtap=disabled
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

    rm -rf "$FFBUILD_DESTPREFIX"/share
}
