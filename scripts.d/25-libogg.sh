#!/bin/bash

SCRIPT_REPO="https://github.com/xiph/ogg.git"
SCRIPT_COMMIT="0288fadac3ac62d453409dfc83e9c4ab617d2472"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    run_autogen build_autotools --with-pic
}
