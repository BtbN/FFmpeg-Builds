#!/bin/bash
source "$(dirname "$BASH_SOURCE")"/linuxloongarch64-gpl.sh
FF_CONFIGURE="--enable-nonfree $FF_CONFIGURE"
LICENSE_FILE=""
