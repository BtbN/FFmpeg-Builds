#!/bin/bash
source "$(dirname "$BASH_SOURCE")"/linux32-gpl-shared.sh
FF_CONFIGURE="--enable-nonfree $FF_CONFIGURE"
