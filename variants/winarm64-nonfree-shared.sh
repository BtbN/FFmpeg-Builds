#!/bin/bash
source "$(dirname "$BASH_SOURCE")"/win64-gpl-shared.sh
FF_CONFIGURE="--enable-nonfree $FF_CONFIGURE"
