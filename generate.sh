#!/bin/bash
set -e
shopt -s globstar
cd "$(dirname "$0")"
source util/vars.sh
source util/build_helpers.sh

export LC_ALL=C.UTF-8

rm -f Dockerfile Dockerfile.{dl,final,dl.final}

layername() {
    printf "layer-"
    # Use parameter expansion instead of basename | sed
    local name="${1##*/}"
    echo "${name%.sh}"
}

resolvestage() {
    [[ -d "$1" ]] && local SCRIPTDIR=("$1") || local SCRIPTDIR=(scripts.d/??-"$1")
    if [[ -d "${SCRIPTDIR[0]}" ]]; then
        echo scripts.d/??-"${1}"
    else
        echo scripts.d/??-"${1}.sh"
    fi
}

resolvescript() {
    local STAGE="$(resolvestage "$1")"
    if [[ -d "$STAGE" ]]; then
        # Use bash array instead of ls | tail
        local scripts=("$STAGE"/*.sh)
        echo "${scripts[-1]}"
    else
        echo "$STAGE"
    fi
}

to_df() {
    local _of="${TODF:-Dockerfile}"
    printf "$@" >> "$_of"
    echo >> "$_of"
}

###
### Generate main Dockerfile
###

exec_dockerstage() {
    SCRIPT="$1"
    (
        SELF="$SCRIPT"
        # Use parameter expansion instead of basename | sed
        local name="${SCRIPT##*/}"
        STAGENAME="${name%.sh}"
        source util/dl_functions.sh
        source "$SCRIPT"

        ffbuild_enabled || exit 0

        to_df "ENV SELF=\"$SELF\" STAGENAME=\"$STAGENAME\""

        STG="$(ffbuild_dockerdl)"
        if [[ -n "$STG" ]]; then
            # Use read to extract first field instead of cut
            local HASH
            read -r HASH _ < <(sha256sum <<<"$STG")
            export SELFCACHE=".cache/downloads/${STAGENAME}_${HASH}.tar.xz"
        fi

        ffbuild_dockerstage || exit $?
    )
}

get_stagedeps() {
    [[ -d "$1" ]] && local SCRIPTDIR=("$1") || local SCRIPTDIR=(scripts.d/??-"$1")
    if [[ -d "${SCRIPTDIR[0]}" ]]; then
        RESDEPS=()
        for SUBSCRIPT in "${SCRIPTDIR[0]}"/*.sh; do
            RESDEPS+=( $(get_stagedeps "${SUBSCRIPT}") )
        done
        tr ' ' '\n' <<< "${RESDEPS[@]}" | sort -u
    else
        [[ -f "$1" ]] && SCRIPT=("$1") || SCRIPT=(scripts.d/??-"${1}.sh")
        SCRIPT="${SCRIPT[0]}"
        (
            SELF="$SCRIPT"
            # Use parameter expansion instead of basename | sed
            local name="${SCRIPT##*/}"
            STAGENAME="${name%.sh}"
            source util/dl_functions.sh
            source "$SCRIPT"

            ffbuild_enabled || exit 0
            ffbuild_depends
        )
    fi
}

# Memoization cache for recursive dependency resolution
declare -A RECURSIVE_DEPS_CACHE

get_stagedeps_recursive_internal() {
    local key="$1"

    # Check cache first to avoid redundant work
    if [[ -v RECURSIVE_DEPS_CACHE["$key"] ]]; then
        echo "${RECURSIVE_DEPS_CACHE[$key]}"
        return 0
    fi

    local CDEPS=($(get_stagedeps "$key"))
    local all_deps=()

    for CDEP in "${CDEPS[@]}"; do
        all_deps+=( $(get_stagedeps_recursive_internal "$CDEP") )
    done
    all_deps+=( "${CDEPS[@]}" )

    # Cache the result
    local result=$(printf '%s\n' "${all_deps[@]}")
    RECURSIVE_DEPS_CACHE["$key"]="$result"
    echo "$result"
}

get_stagedeps_recursive() {
    declare -A ALREADY_PRINTED
    for CDEP in $(get_stagedeps_recursive_internal "$1"); do
        if ! [[ -v ALREADY_PRINTED["$CDEP"] ]]; then
            echo "$CDEP"
            ALREADY_PRINTED["$CDEP"]="1"
        fi
    done
}

get_filled_deps() {
    local CUR_DEPS=($(get_stagedeps "$1"))
    local UNFILLED_DEPS=()
    for DEP in "${CUR_DEPS[@]}"; do
        [[ -v FILLED_DEPS["$DEP"] ]] || UNFILLED_DEPS+=("$DEP")
    done
    if [[ "${#UNFILLED_DEPS[@]}" -eq 0 ]]; then
        echo "$1"
    else
        for DEP in "${UNFILLED_DEPS[@]}"; do
            get_filled_deps "$DEP" | sort -u
        done
    fi
}

# Optimized get_output that sources each script only once
# Usage: get_all_outputs SCRIPT_PATH
# Returns: Newline-separated values for configure, cflags, cxxflags, ldflags, ldexeflags, libs
get_all_outputs() {
    (
        SELF="$1"
        source "$1"

        if ffbuild_enabled; then
            echo "CONFIGURE:$(ffbuild_configure || echo '')"
            echo "CFLAGS:$(ffbuild_cflags || echo '')"
            echo "CXXFLAGS:$(ffbuild_cxxflags || echo '')"
            echo "LDFLAGS:$(ffbuild_ldflags || echo '')"
            echo "LDEXEFLAGS:$(ffbuild_ldexeflags || echo '')"
            echo "LIBS:$(ffbuild_libs || echo '')"
        else
            echo "CONFIGURE:$(ffbuild_unconfigure || echo '')"
            echo "CFLAGS:$(ffbuild_uncflags || echo '')"
            echo "CXXFLAGS:$(ffbuild_uncxxflags || echo '')"
            echo "LDFLAGS:$(ffbuild_unldflags || echo '')"
            echo "LDEXEFLAGS:$(ffbuild_unldexeflags || echo '')"
            echo "LIBS:$(ffbuild_unlibs || echo '')"
        fi
    )
}

# Legacy get_output function for compatibility (kept for other uses in script)
get_output() {
    (
        SELF="$1"
        source "$1"
        if ffbuild_enabled; then
            ffbuild_$2 || exit 0
        else
            ffbuild_un$2 || exit 0
        fi
    )
}

export TODF="Dockerfile"

BASELAYER="base-layer"
to_df "FROM ${REGISTRY}/${REPO}/base-${TARGET}:latest AS ${BASELAYER}"
to_df "ENV TARGET=$TARGET VARIANT=$VARIANT REPO=$REPO ADDINS_STR=$ADDINS_STR"
to_df "COPY --link util/run_stage.sh /usr/bin/run_stage"

for addin in "${ADDINS[@]}"; do
(
    source addins/"${addin}.sh"
    type ffbuild_dockeraddin &>/dev/null && ffbuild_dockeraddin || true
)
done

# Use bash array instead of ls | tail
ENTRYSCRIPT_ARRAY=(scripts.d/*)
ENTRYSCRIPT="${ENTRYSCRIPT_ARRAY[-1]}"
declare -A FILLED_DEPS
while true; do
    CURDEPS=($(get_filled_deps "$ENTRYSCRIPT" | sort -u))
    if [[ "${CURDEPS[@]}" == "$ENTRYSCRIPT" ]]; then
        break
    fi
    for CURDEP in "${CURDEPS[@]}"; do
        FILLED_DEPS["$CURDEP"]="1"

        SCRIPT="$(resolvescript "$CURDEP")"
        (
            SELF="$SCRIPT"
            source "$SCRIPT"
            ffbuild_enabled || exit $?
            to_df "FROM ${BASELAYER} AS ${CURDEP}"
        ) || continue

        for SUBDEP in $(get_stagedeps_recursive "${CURDEP}"); do
            SCRIPT="$(resolvescript "$SUBDEP")"
            (
                SELF="$SCRIPT"
                SELFLAYER="$SUBDEP"
                source "$SCRIPT"
                ffbuild_enabled || exit 0
                ffbuild_dockerlayer || exit $?
            )
        done

        STAGE="$(resolvestage "$CURDEP")"
        if [[ -d "$STAGE" ]]; then
            for STAGE in "${STAGE}"/??-*.sh; do
                exec_dockerstage "$STAGE"
            done
        else
            exec_dockerstage "$STAGE"
        fi
    done
done

source "variants/${TARGET}-${VARIANT}.sh"

for addin in ${ADDINS[*]}; do
    source "addins/${addin}.sh"
done

COMBINELAYER="combine-layer"
to_df "FROM ${BASELAYER} AS ${COMBINELAYER}"
for SUBDEP in $(get_stagedeps_recursive "${ENTRYSCRIPT}"); do
    STAGE="$(resolvestage "$SUBDEP")"
    [[ -d "$STAGE" ]] && SCRIPTS=("${STAGE}"/??-*.sh) || SCRIPTS=("${STAGE}")

    SCRIPT="${SCRIPTS[-1]}"
    (
        SELF="$SCRIPT"
        COMBINING="1"
        SELFLAYER="$SUBDEP"
        source "$SCRIPT"
        ffbuild_enabled || exit 0
        ffbuild_dockerlayer || exit $?
        TODF="Dockerfile.final" PREVLAYER="$COMBINELAYER" \
            ffbuild_dockerfinal || exit $?
    )

    # Optimized: source each script only once instead of 6 times
    for SCRIPT in "${SCRIPTS[@]}"; do
        while IFS=: read -r key value; do
            case "$key" in
                CONFIGURE) FF_CONFIGURE+=" $value" ;;
                CFLAGS) FF_CFLAGS+=" $value" ;;
                CXXFLAGS) FF_CXXFLAGS+=" $value" ;;
                LDFLAGS) FF_LDFLAGS+=" $value" ;;
                LDEXEFLAGS) FF_LDEXEFLAGS+=" $value" ;;
                LIBS) FF_LIBS+=" $value" ;;
            esac
        done < <(get_all_outputs "$SCRIPT")
    done
done

to_df "FROM ${BASELAYER}"
sort -u < Dockerfile.final >> Dockerfile
rm Dockerfile.final

# Use helper function to normalize flags (reduces duplication)
FF_CONFIGURE="$(normalize_flags "$FF_CONFIGURE")"
FF_CFLAGS="$(normalize_flags "$FF_CFLAGS")"
FF_CXXFLAGS="$(normalize_flags "$FF_CXXFLAGS")"
FF_LDFLAGS="$(normalize_flags "$FF_LDFLAGS")"
FF_LDEXEFLAGS="$(normalize_flags "$FF_LDEXEFLAGS")"
FF_LIBS="$(normalize_flags "$FF_LIBS")"

to_df "ENV \\"
to_df "    FF_CONFIGURE=\"$FF_CONFIGURE\" \\"
to_df "    FF_CFLAGS=\"$FF_CFLAGS\" \\"
to_df "    FF_CXXFLAGS=\"$FF_CXXFLAGS\" \\"
to_df "    FF_LDFLAGS=\"$FF_LDFLAGS\" \\"
to_df "    FF_LDEXEFLAGS=\"$FF_LDEXEFLAGS\" \\"
to_df "    FF_LIBS=\"$FF_LIBS\""
