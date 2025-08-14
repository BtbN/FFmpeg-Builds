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

# If this is a sub-stage, hardlink-copy the DESTDIR into the PREFIX.
# So the following layers can actually use the installed stuff.
if [[ "$SELF" == */??-*/??-*.sh ]]; then
    cp -al "$FFBUILD_DESTDIR"/. /
fi

rm -rf "$FFBUILD_DESTPREFIX"/bin

if [[ -n "$STAGENAME" ]]; then
    rm -rf "/$STAGENAME"
fi
