#!/bin/bash
source "$(dirname "$BASH_SOURCE")"/win64-gpl.sh
FF_CONFIGURE="--enable-nonfree $FF_CONFIGURE"
LICENSE_FILE=""
