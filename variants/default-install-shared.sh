#!/bin/bash

package_variant() {
    IN="$1"
    OUT="$2"

    mkdir -p "$OUT"/bin
    cp "$IN"/bin/*.{exe,dll} "$OUT"/bin

    mkdir -p "$OUT"/lib
    cp "$IN"/bin/*.lib "$OUT"/lib
    cp "$IN"/lib/*.{def,dll.a} "$OUT"/lib

    mkdir -p "$OUT"/include
    cp -r "$IN"/include/* "$OUT"/include

    mkdir -p "$OUT/doc"
    cp -r "$IN"/share/doc/ffmpeg/* "$OUT"/doc
}
