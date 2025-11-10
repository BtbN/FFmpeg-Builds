#!/bin/bash
source "$(dirname "$BASH_SOURCE")"/package-helpers.sh

package_variant() {
    IN="$1"
    OUT="$2"

    cp "$IN"/bin/*.{exe,dll} "$OUT"/bin

    mkdir -p "$OUT"/lib
    cp "$IN"/bin/*.lib "$OUT"/lib
    cp "$IN"/lib/*.{def,dll.a} "$OUT"/lib

    package_shared_libs "$IN" "$OUT"
    package_common "$IN" "$OUT"
}
