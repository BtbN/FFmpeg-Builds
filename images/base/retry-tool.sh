#!/bin/bash
set -xe

RETRY_COUNTER=0
MAX_RETRY=15
while [[ $RETRY_COUNTER -lt $MAX_RETRY ]]; do
    timeout 120 "$@" && break || sleep 10
    RETRY_COUNTER=$(( $RETRY_COUNTER + 1 ))
    echo "Retry $RETRY_COUNTER..."
done
if [[ $RETRY_COUNTER -ge $MAX_RETRY ]]; then
    echo "Max retry count exceeded."
    exit 1
fi
