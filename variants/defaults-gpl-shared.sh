#!/bin/bash
source "$(dirname "$BASH_SOURCE")"/defaults-gpl.sh
#FF_CONFIGURE+=" --enable-shared --disable-static --disable-programs --disable-filters --disable-devices --disable-encoders --disable-muxers --disable-protocols"
FF_CONFIGURE+=" --enable-shared --disable-static --disable-filters --disable-devices --disable-encoders"
