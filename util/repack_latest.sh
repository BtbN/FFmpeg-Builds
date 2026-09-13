#!/bin/bash
set -e

if [[ $# -lt 2 ]]; then
    echo "Missing arguments"
    exit -1
fi

RELEASE_DIR="$(realpath "$1")"
shift
mkdir -p "$RELEASE_DIR"

while [[ $# -gt 0 ]]; do
    INPUT="$1"
    shift

    (
        set -e

        if [[ $INPUT == *.zip ]]; then
            OUTEXT="zip"
        elif [[ $INPUT == *.7z ]]; then
            OUTEXT="7z"
        elif [[ $INPUT == *.tar.xz ]]; then
            OUTEXT="tar.xz"
        else
            echo "Unknown input file type: $INPUT"
            exit 1
        fi

        INAME="$(bsdtar -tf "$INPUT" | head -1 | cut -d/ -f1)"
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

        OUTPUT="$RELEASE_DIR/$ONAME.$OUTEXT"

        if [[ $OUTEXT == tar.xz ]]; then
            bsdtar -cf "$OUTPUT" --format gnutar --xz --options xz:threads=0 -s "|^$INAME/|$ONAME/|" "@$INPUT"
        else
            cp "$INPUT" "$OUTPUT"
            7z rn -bso0 -bsp0 "$OUTPUT" "$INAME" "$ONAME"
            [[ "$(bsdtar -tf "$OUTPUT" | head -1 | cut -d/ -f1)" == "$ONAME" ]]
        fi
    ) &

    while [[ $(jobs | wc -l) -gt 3 ]]; do
        wait %1
    done
done

while [[ $(jobs | wc -l) -gt 0 ]]; do
    wait %1
done
