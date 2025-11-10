#!/bin/bash
# Common packaging helper functions to reduce duplication

# Copy common files that all variants need
package_common() {
    local IN="$1"
    local OUT="$2"

    mkdir -p "$OUT"/bin
    mkdir -p "$OUT/doc"
    mkdir -p "$OUT/presets"

    cp -r "$IN"/share/doc/ffmpeg/* "$OUT"/doc
    cp "$IN"/share/ffmpeg/*.ffpreset "$OUT"/presets
}

# Copy man pages (Linux only)
package_man_pages() {
    local IN="$1"
    local OUT="$2"

    mkdir -p "$OUT/man"
    cp -r "$IN"/share/man/* "$OUT"/man
}

# Copy shared library files and development headers
package_shared_libs() {
    local IN="$1"
    local OUT="$2"

    mkdir -p "$OUT"/lib/pkgconfig
    mkdir -p "$OUT"/include

    cp -a "$IN"/lib/pkgconfig/*.pc "$OUT"/lib/pkgconfig
    sed -i \
        -e 's|^prefix=.*|prefix=${pcfiledir}/../..|' \
        -e 's|/ffbuild/prefix|${prefix}|' \
        -e '/Libs.private:/d' \
        "$OUT"/lib/pkgconfig/*.pc

    cp -r "$IN"/include/* "$OUT"/include
}
