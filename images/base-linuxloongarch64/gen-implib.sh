#!/bin/bash
set -e
if [[ $# != 2 ]]; then
    echo "Invalid arguments"
    exit 1
fi
IN="$1"
OUT="$2"

TMPDIR="$(mktemp -d)"
trap "rm -rf '$TMPDIR'" EXIT
cd "$TMPDIR"

set -x
python3 /opt/implib/implib-gen.py --target aarch64-linux-gnu --dlopen --lazy-load --verbose "$IN"
${FFBUILD_CROSS_PREFIX}gcc $CFLAGS $STAGE_CFLAGS -Wa,--noexecstack -DIMPLIB_HIDDEN_SHIMS -c *.tramp.S *.init.c
${FFBUILD_CROSS_PREFIX}ar -rcs "$OUT" *.tramp.o *.init.o
