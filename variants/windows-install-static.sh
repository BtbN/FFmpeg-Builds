#!/bin/bash
source "$(dirname "$BASH_SOURCE")"/package-helpers.sh

package_variant() {
    IN="$1"
    OUT="$2"

    cp "$IN"/bin/* "$OUT"/bin
    package_common "$IN" "$OUT"
}
