#!/bin/bash
set -xe
FNAME="$1"
URL="$2"
SHA512="$3"
SHAFILE="${FNAME}.sha512"
wget -O "${FNAME}" "${URL}"
trap "rm -f ${SHAFILE}" EXIT
echo "${SHA512}  ${FNAME}" > "${SHAFILE}"
sha512sum -c "${SHAFILE}"
