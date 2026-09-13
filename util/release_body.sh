#!/bin/bash
set -e

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <tagname> <file> [file ...]"
    exit -1
fi

TAGNAME="$1"
shift

REPO="${GITHUB_REPOSITORY:-BtbN/FFmpeg-Builds}"
DL_BASE="https://github.com/${REPO}/releases/download/${TAGNAME}"

TARGETS=(win64 winarm64 win32 linux64 linuxarm64 linux32)
VARIANTS=(gpl gpl-shared lgpl lgpl-shared)

target_name() {
    case "$1" in
        win64)       echo "Windows (x86_64)" ;;
        winarm64)    echo "Windows (arm64)" ;;
        win32)       echo "Windows (x86)" ;;
        linux64)     echo "Linux (x86_64)" ;;
        linuxarm64)  echo "Linux (arm64)" ;;
        linux32)     echo "Linux (x86)" ;;
        *)           echo "$1" ;;
    esac
}

variant_name() {
    case "$1" in
        gpl)            echo "GPL, static" ;;
        lgpl)           echo "LGPL, static" ;;
        gpl-shared)     echo "GPL, shared" ;;
        lgpl-shared)    echo "LGPL, shared" ;;
        *)              echo "$1" ;;
    esac
}

declare -A ROWS
declare -A VERSIONS
declare -A GROUP_SEEN

for FILE in "$@"; do
    FNAME="$(basename "$FILE")"
    BASE="${FNAME%.zip}"
    BASE="${BASE%.tar.xz}"

    TARGET=""
    for T in "${TARGETS[@]}"; do
        if [[ $BASE == *"-${T}-"* ]]; then
            TARGET="$T"
            VERSION="${BASE%%-${T}-*}"
            VARIANT="${BASE#*-${T}-}"
            break
        fi
    done
    if [[ -z $TARGET ]]; then
        echo "Skipping unrecognized artifact: $BASE" >&2
        continue
    fi

    VERSION="${VERSION#ffmpeg-}"
    case "${VERSION%%-*}" in
        N|master)
            GROUP="master"
            ;;
        n[0-9]*)
            GROUP="$(sed -E 's/^n([0-9]+\.[0-9]+).*/\1/' <<<"${VERSION%%-*}")"
            VARIANT="${VARIANT%-${GROUP}}"
            ;;
        *)
            GROUP="${VERSION%%-*}"
            VARIANT="${VARIANT%-${GROUP}}"
            ;;
    esac

    MATCH=""
    ADDINS=""
    for V in "${VARIANTS[@]}"; do
        if [[ ( $VARIANT == "$V" || $VARIANT == "$V"-* ) && ${#V} -gt ${#MATCH} ]]; then
            MATCH="$V"
        fi
    done
    if [[ -n $MATCH ]]; then
        ADDINS="${VARIANT#$MATCH}"
        ADDINS="${ADDINS#-}"
        VARIANT="$MATCH"
    else
        VARIANTS+=( "$VARIANT" )
    fi

    SIZE="$(numfmt --to=iec-i --suffix=B --format='%.1f' < <(stat -c %s "$FILE"))"

    KEY="${TARGET}|${GROUP}|${VARIANT}"
    ROW="| $(variant_name "$VARIANT")${ADDINS:+ (+$ADDINS)} | [${FNAME}](${DL_BASE}/${FNAME}) | ${SIZE} |"
    if [[ -n $ADDINS ]]; then
        ROWS["$KEY"]="${ROWS["$KEY"]}${ROWS["$KEY"]:+$'\n'}${ROW}"
    else
        ROWS["$KEY"]="${ROW}${ROWS["$KEY"]:+$'\n'}${ROWS["$KEY"]}"
    fi
    VERSIONS["${TARGET}|${GROUP}"]="$VERSION"
    GROUP_SEEN["$GROUP"]=1
done

if [[ ${#ROWS[@]} -eq 0 ]]; then
    echo "No artifacts found" >&2
    exit 1
fi

printf "%s\n\n%s\n\n" "# FFmpeg Builds" "Grouped by OS, version and variant."

GROUP_ORDER=()
[[ -v GROUP_SEEN[master] ]] && GROUP_ORDER+=( master )
while read -r GROUP; do
    GROUP_ORDER+=( "$GROUP" )
done < <(printf '%s\n' "${!GROUP_SEEN[@]}" | grep -vx master | sort -Vr)

for TARGET in "${TARGETS[@]}"; do
    TARGET_GROUPS=()
    for GROUP in "${GROUP_ORDER[@]}"; do
        [[ -v VERSIONS["${TARGET}|${GROUP}"] ]] && TARGET_GROUPS+=( "$GROUP" )
    done
    [[ ${#TARGET_GROUPS[@]} -gt 0 ]] || continue

    printf '<details>\n<summary><b>%s</b></summary>\n\n' "$(target_name "$TARGET")"

    for GROUP in "${TARGET_GROUPS[@]}"; do
        VERSION="${VERSIONS["${TARGET}|${GROUP}"]}"
        if [[ $VERSION == *-latest ]]; then
            printf '<details>\n<summary>%s</summary>\n\n' "$GROUP"
        else
            printf '<details>\n<summary>%s <code>%s</code></summary>\n\n' "$GROUP" "$VERSION"
        fi
        printf '| Variant | File | Size |\n|:--|:--|--:|\n'

        for VARIANT in "${VARIANTS[@]}"; do
            KEY="${TARGET}|${GROUP}|${VARIANT}"
            [[ -v ROWS["$KEY"] ]] && printf '%s\n' "${ROWS["$KEY"]}"
        done

        printf '\n</details>\n'
    done

    printf '\n</details>\n\n'
done

printf "%s\n" "See [checksums.sha256](${DL_BASE}/checksums.sha256) for checksums."
