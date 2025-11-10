#!/bin/bash
source "$(dirname "$BASH_SOURCE")"/package-helpers.sh

package_variant() {
    IN="$1"
    OUT="$2"

    cp "$IN"/bin/* "$OUT"/bin

    mkdir -p "$OUT"/lib
    cp -a "$IN"/lib/*.so* "$OUT"/lib

    package_shared_libs "$IN" "$OUT"
    package_common "$IN" "$OUT"
    package_man_pages "$IN" "$OUT"
}
