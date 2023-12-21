#!/bin/bash
set -xe

export RAW_CFLAGS="$CFLAGS"
export RAW_CXXFLAGS="$CXXFLAGS"
export RAW_LDFLAGS="$LDFLAGS"
[[ -n "$STAGE_CFLAGS" ]] && export CFLAGS="$CFLAGS $STAGE_CFLAGS"
[[ -n "$STAGE_CXXFLAGS" ]] && export CXXFLAGS="$CXXFLAGS $STAGE_CXXFLAGS"
[[ -n "$STAGE_LDFLAGS" ]] && export LDFLAGS="$LDFLAGS $STAGE_LDFLAGS"

git config --global --add safe.directory "$PWD"

source "$1"
if [[ -z "$2" ]]; then
    ffbuild_dockerbuild
else
    "$2"
fi
rm -rf "$FFBUILD_PREFIX"/bin

if [[ -n "$STAGENAME" ]]; then
    rm -rf "/$STAGENAME"
fi
