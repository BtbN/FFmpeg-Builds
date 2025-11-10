#!/bin/bash
# Nonfree variant - extends GPL with proprietary codecs
source "$(dirname "$BASH_SOURCE")"/defaults-gpl.sh
FF_CONFIGURE="--enable-nonfree $FF_CONFIGURE"
LICENSE_FILE=""
