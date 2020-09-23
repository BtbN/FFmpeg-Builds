#!/bin/bash
source "$(dirname "$BASH_SOURCE")"/defaults-gpl.sh
FF_CONFIGURE+=" --enable-shared --disable-static"
