#!/bin/bash
set -xe

export RAW_CFLAGS="$CFLAGS"
export RAW_CXXFLAGS="$CXXFLAGS"
export RAW_LDFLAGS="$LDFLAGS"
[[ -n "$STAGE_CFLAGS" ]] && export CFLAGS="$CFLAGS $STAGE_CFLAGS"
[[ -n "$STAGE_CXXFLAGS" ]] && export CXXFLAGS="$CXXFLAGS $STAGE_CXXFLAGS"
[[ -n "$STAGE_LDFLAGS" ]] && export LDFLAGS="$LDFLAGS $STAGE_LDFLAGS"

mkdir -p /stage
source "$1"
cd /stage
if [[ -n "$3" ]]; then
    cd "$3"
fi
if [[ -z "$2" ]]; then
    ffbuild_dockerbuild
else
    "$2"
fi
rm -rf /stage "$FFBUILD_PREFIX"/bin
