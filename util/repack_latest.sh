#!/bin/bash
set -e

if [[ $# -lt 2 ]]; then
    echo "Missing arguments"
    exit -1
fi

RELEASE_DIR="$(realpath "$1")"
shift

rm -rf repack_dir
mkdir repack_dir
trap "rm -rf repack_dir" EXIT

while [[ $# -gt 0 ]]; do
    INPUT="$1"
    shift

    rm -rf repack_dir/*

    if [[ $INPUT == *.zip ]]; then
        unzip "$INPUT" -d repack_dir
    elif [[ $INPUT == *.tar.xz ]]; then
        tar xvaf "$INPUT" -C repack_dir
    else
        echo "Unknown input file type: $INPUT"
        exit 1
    fi

    cd repack_dir

    INAME="$(echo ffmpeg-*)"
    TAGNAME="$(cut -d- -f2 <<<"$INAME")"

    if [[ $TAGNAME == N ]]; then
        TAGNAME="master"
    elif [[ $TAGNAME == n* ]]; then
        TAGNAME="$(sed -re 's/([0-9]+\.[0-9]+).*/\1/' <<<"$TAGNAME")"
    fi

    ONAME="ffmpeg-$TAGNAME-latest-$(cut -d- -f5- <<<"$INAME")"
    mv "$INAME" "$ONAME"

    if [[ $INPUT == *.zip ]]; then
        zip -9 -r "$RELEASE_DIR/$ONAME.zip" "$ONAME"
    elif [[ $INPUT == *.tar.xz ]]; then
        tar cvJf "$RELEASE_DIR/$ONAME.tar.xz" "$ONAME"
    fi

    cd ..
done
