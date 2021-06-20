#!/bin/bash
source "$(dirname "$BASH_SOURCE")"/linux64-gpl-shared.sh
FF_CONFIGURE="--enable-nonfree $FF_CONFIGURE"
