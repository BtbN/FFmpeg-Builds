#!/bin/bash

SCRIPT_SKIP="1"

ffbuild_depends() {
    echo base
    echo rav1e
    echo librsvg
}

ffbuild_enabled() {
    ( source scripts.d/50-rav1e.sh && ffbuild_enabled ) || return -1
    ( source scripts.d/50-librsvg/99-librsvg.sh && ffbuild_enabled ) || return -1
    return 0
}

ffbuild_dockerdl() {
    return 0
}

ffbuild_dockerbuild() {
    local NM="${FFBUILD_CROSS_PREFIX}nm"
    local AR="${FFBUILD_CROSS_PREFIX}ar"
    local OBJCOPY="${FFBUILD_CROSS_PREFIX}objcopy"

    ffbuild_libfile() {
        local lib="$(pkg-config --libs-only-l "$1" | awk '{ print $1 }')"
        echo "$FFBUILD_PREFIX/lib/lib${lib#-l}.a"
    }

    globalsyms() {
        "$NM" --defined-only "$1" | awk '$2 ~ /^[A-Z]$/ { print $3 }' | sort -u
    }

    local RAV1E="$(ffbuild_libfile rav1e)"
    local RSVG="$(ffbuild_libfile librsvg-2.0)"
    [[ -f "$RAV1E" && -f "$RSVG" ]] || return -1

    local OUT="$FFBUILD_DESTPREFIX/lib/$(basename "$RSVG")"
    mkdir -p "$(dirname "$OUT")"
    cp "$RSVG" "$OUT"

    # Identify and rename every rust-mangled symbol and handle import-lib symbol prefix
    comm -12 <(globalsyms "$RAV1E") <(globalsyms "$OUT") | awk '{
        sym = $1; prefix = ""; base = sym
        if (sym ~ /^__imp_/) { prefix = "__imp_"; base = substr(sym, 7) }
        if (base ~ /^_(R|ZN)/ || base == "rust_eh_personality")
            print sym " " prefix "ffdedup_" base
    }' > rename.map

    echo "${OUT##*/}: renaming $(wc -l < rename.map) symbols:"
    [[ -s rename.map ]] || return -1
    cat rename.map

    # Only patch rust objects, since they're guaranteed to not exist multiple times
    local MEMBERS=( $("$AR" t "$OUT" | grep '\.rcgu\.o$') )

    mkdir objs && cd objs
    "$AR" x "$OUT" "${MEMBERS[@]}"
    local member
    for member in "${MEMBERS[@]}"; do
        "$OBJCOPY" --redefine-syms=../rename.map "$member"
    done
    "$AR" r "$OUT" "${MEMBERS[@]}"
}
