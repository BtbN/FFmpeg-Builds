#!/bin/bash

default_dl() {
    echo "git-mini-clone \"$SCRIPT_REPO\" \"$SCRIPT_COMMIT\" \"$1\""
}

ffbuild_dockerdl() {
    default_dl .
}
