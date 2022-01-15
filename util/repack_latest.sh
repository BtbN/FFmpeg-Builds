#!/bin/bash
set -e

if [[ $# -lt 2 ]]; then
    echo "Missing arguments"
    exit -1
fi

RELEASE_DIR="$(realpath "$1")"
shift
mkdir -p "$RELEASE_DIR"

rm -rf repack_dir
mkdir repack_dir
trap "rm -rf repack_dir" EXIT

while [[ $# -gt 0 ]]; do
    INPUT="$1"
    shift

    (
        set -e
        REPACK_DIR="repack_dir/$BASHPID"
        rm -rf "$REPACK_DIR"
        mkdir "$REPACK_DIR"

        if [[ $INPUT == *.zip ]]; then
            unzip "$INPUT" -d "$REPACK_DIR"
        elif [[ $INPUT == *.tar.xz ]]; then
            tar xvaf "$INPUT" -C "$REPACK_DIR"
        else
            echo "Unknown input file type: $INPUT"
            exit 1
        fi

        cd "$REPACK_DIR"

        INAME="$(echo ffmpeg-*)"
        TAGNAME="$(cut -d- -f2 <<<"$INAME")"

        if [[ $TAGNAME == N ]]; then
            TAGNAME="master"
        elif [[ $TAGNAME == n* ]]; then
            TAGNAME="$(sed -re 's/([0-9]+\.[0-9]+).*/\1/' <<<"$TAGNAME")"
        fi

        if [[ "$INAME" =~ -[0-9]+-g ]]; then
            ONAME="ffmpeg-$TAGNAME-latest-$(cut -d- -f5- <<<"$INAME")"
        else
            ONAME="ffmpeg-$TAGNAME-latest-$(cut -d- -f3- <<<"$INAME")"
        fi

        mv "$INAME" "$ONAME"

        if [[ $INPUT == *.zip ]]; then
            zip -9 -r "$RELEASE_DIR/$ONAME.zip" "$ONAME"
        elif [[ $INPUT == *.tar.xz ]]; then
            tar cvJf "$RELEASE_DIR/$ONAME.tar.xz" "$ONAME"
        fi

        rm -rf "$REPACK_DIR"
    ) &

    while [[ $(jobs | wc -l) -gt 3 ]]; do
        wait %1
    done
done

while [[ $(jobs | wc -l) -gt 0 ]]; do
    wait %1
done
rm -rf repack_dir
