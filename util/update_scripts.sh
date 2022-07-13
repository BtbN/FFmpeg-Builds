#!/bin/bash
set -eo pipefail
shopt -s globstar
export LC_ALL=C

cd "$(dirname "$0")"/..

for scr in scripts.d/**/*.sh; do
echo "Processing ${scr}"
(
    source "$scr"

    if [[ -n "$SCRIPT_SKIP" ]]; then
        exit 0
    fi

    for i in "" $(seq 2 9); do
        REPO_VAR="SCRIPT_REPO$i"
        COMMIT_VAR="SCRIPT_COMMIT$i"
        REV_VAR="SCRIPT_REV$i"
        HGREV_VAR="SCRIPT_HGREV$i"
        BRANCH_VAR="SCRIPT_BRANCH$i"
        TAGFILTER_VAR="SCRIPT_TAGFILTER$i"

        CUR_REPO="${!REPO_VAR}"
        CUR_COMMIT="${!COMMIT_VAR}"
        CUR_REV="${!REV_VAR}"
        CUR_HGREV="${!HGREV_VAR}"
        CUR_BRANCH="${!BRANCH_VAR}"
        CUR_TAGFILTER="${!TAGFILTER_VAR}"

        if [[ -z "${CUR_REPO}" ]]; then
            if [[ -z "$i" ]]; then
                # Mark scripts without repo source for manual check
                echo "xxx_CHECKME_xxx" >> "$scr"
                echo "Needs manual check."
            fi
            break
        fi

        if [[ -n "${CUR_REV}" ]]; then # SVN
            echo "Checking svn rev for ${CUR_REPO}..."
            NEW_REV="$(svn info --password="" "${CUR_REPO}" | grep ^Revision: | cut -d" " -f2 | xargs)"
            echo "Got ${NEW_REV} (current: ${CUR_REV})"

            if [[ "${NEW_REV}" != "${CUR_REV}" ]]; then
                echo "Updating ${scr}"
                sed -i "s/^${REV_VAR}=.*/${REV_VAR}=\"${NEW_REV}\"/" "${scr}"
            fi
        elif [[ -n "${CUR_HGREV}" ]]; then # HG
            hg init tmphgrepo
            trap "rm -rf tmphgrepo" EXIT
            cd tmphgrepo
            NEW_HGREV="$(hg in -f -n -l 1 "${CUR_REPO}" | grep changeset | cut -d: -f3 | xargs)"
            cd ..
            rm -rf tmphgrepo

            echo "Got ${NEW_HGREV} (current: ${CUR_HGREV})"

            if [[ "${NEW_HGREV}" != "${CUR_HGREV}" ]]; then
                echo "Updating ${scr}"
                sed -i "s/^${HGREV_VAR}=.*/${HGREV_VAR}=\"${NEW_HGREV}\"/" "${scr}"
            fi
        elif [[ -n "${CUR_COMMIT}" ]]; then # GIT
            if [[ -n "${CUR_TAGFILTER}" ]]; then
                NEW_COMMIT="$(git -c 'versionsort.suffix=-' ls-remote --exit-code --tags --refs --sort "v:refname" "${CUR_REPO}" "refs/tags/${CUR_TAGFILTER}" | tail -n1 | cut -d/ -f3- | xargs)"
            else
                if [[ -z "${CUR_BRANCH}" ]]; then
                    # Fetch default branch name
                    CUR_BRANCH="$(git remote show "${CUR_REPO}" | grep "HEAD branch:" | cut -d":" -f2 | xargs)"
                    echo "Found default branch ${CUR_BRANCH}"
                fi
                NEW_COMMIT="$(git ls-remote --exit-code --heads --refs "${CUR_REPO}" refs/heads/"${CUR_BRANCH}" | cut -f1)"
            fi

            echo "Got ${NEW_COMMIT} (current: ${CUR_COMMIT})"

            if [[ "${NEW_COMMIT}" != "${CUR_COMMIT}" ]]; then
                echo "Updating ${scr}"
                sed -i "s/^${COMMIT_VAR}=.*/${COMMIT_VAR}=\"${NEW_COMMIT}\"/" "${scr}"
            fi
        else
            # Mark scripts with unknown layout for manual check
            echo "xxx_CHECKME_UNKNOWN_xxx" >> "$scr"
            echo "Unknown layout. Needs manual check."
            break
        fi
    done
)
echo
done
