#!/bin/bash
set -xe

export RAW_CFLAGS="$CFLAGS"
export RAW_CXXFLAGS="$CXXFLAGS"
export RAW_LDFLAGS="$LDFLAGS"
[[ -n "$STAGE_CFLAGS" ]] && export CFLAGS="$CFLAGS $STAGE_CFLAGS"
[[ -n "$STAGE_CXXFLAGS" ]] && export CXXFLAGS="$CXXFLAGS $STAGE_CXXFLAGS"
[[ -n "$STAGE_LDFLAGS" ]] && export LDFLAGS="$LDFLAGS $STAGE_LDFLAGS"

if [[ -n "$STAGENAME" && -f /cache.tar.xz ]]; then
    mkdir -p "/$STAGENAME"
    tar xaf /cache.tar.xz -C "/$STAGENAME"
    cd "/$STAGENAME"
elif [[ -n "$STAGENAME" ]]; then
    mkdir -p "/$STAGENAME"
    cd "/$STAGENAME"
fi

git config --global --add safe.directory "$PWD"

source "$1"
if [[ -z "$2" ]]; then
    ffbuild_dockerbuild
else
    "$2"
fi

if [[ -d "$FFBUILD_DESTDIR" ]]; then
    # Remove legacy libtool .la files
    find "$FFBUILD_DESTDIR" -name "*.la" -delete

    # Strip all plain .a archives, but only if they actually shrink
    STRIP_ARGS=( --strip-unneeded )
    [[ "$ADDINS_STR" != *debug* ]] && STRIP_ARGS+=( --strip-debug )
    STRIP_BIN="${STRIP:-${FFBUILD_CROSS_PREFIX}strip}"
    RANLIB_BIN="${RANLIB:-${FFBUILD_CROSS_PREFIX}ranlib}"

    find "$FFBUILD_DESTDIR" -type f -name '*.a' ! -name '*.dll.a' -print0 | while IFS= read -r -d '' lib; do
        tmp="${lib}.strip"
        cp -p "$lib" "$tmp" || continue
        if "$STRIP_BIN" "${STRIP_ARGS[@]}" "$tmp" \
            && "$RANLIB_BIN" "$tmp" \
            && (( $(stat -c %s "$tmp") < $(stat -c %s "$lib") )); then
            mv -f "$tmp" "$lib"
        else
            rm -f "$tmp"
        fi
    done
fi

# If this is a sub-stage, hardlink-copy the DESTDIR into the PREFIX.
# So the following layers can actually use the installed stuff.
if [[ "$SELF" == */??-*/??-*.sh && -d "$FFBUILD_DESTDIR" ]]; then
    cp -al "$FFBUILD_DESTDIR"/. /
fi

rm -rf "$FFBUILD_DESTPREFIX"/bin

if [[ -n "$STAGENAME" ]]; then
    rm -rf "/$STAGENAME"
fi
