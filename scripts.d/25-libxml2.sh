#!/bin/bash

SCRIPT_REPO="https://github.com/GNOME/libxml2.git"
SCRIPT_COMMIT="22f9d730898d2dfcc03a484e65e1f8fc3675225f"

ffbuild_depends() {
    echo base
    echo libiconv
}

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    run_autogen build_autotools --without-python --disable-maintainer-mode
}

ffbuild_configure() {
    echo $(ffbuild_enable libxml2)
}

ffbuild_unconfigure() {
    echo $(ffbuild_disable libxml2)
}
