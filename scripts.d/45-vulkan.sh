#!/bin/bash

LUNARG_VERSION="1.2.148.1"
LUNARG_SRC="https://sdk.lunarg.com/sdk/download/${LUNARG_VERSION}/windows/VulkanSDK-${LUNARG_VERSION}-Installer.exe"

ffbuild_enabled() {
    [[ $VARIANT != *vulkan* ]] && return -1
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    mkdir vulkan && cd vulkan

    if [[ $TARGET == win64 ]]; then
        wget --no-cookies -O vulkan.exe "$LUNARG_SRC"
        7z x vulkan.exe Include/vulkan Lib/vulkan-1.lib

        find . -type f -exec chmod 644 {} \;
        find . -type d -exec chmod 755 {} \;

        mv Include/* "$FFBUILD_PREFIX"/include/.
        mv Lib/* "$FFBUILD_PREFIX"/lib/.
        
        mkdir -p "$FFBUILD_PREFIX"/lib/pkgconfig
        cat > "$FFBUILD_PREFIX"/lib/pkgconfig/vulkan.pc <<EOF
prefix=$FFBUILD_PREFIX
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: Vulkan-Loader
Description: Vulkan Loader
Version: $LUNARG_VERSION
Libs: -L\${libdir} -lvulkan-1 -ladvapi32
Cflags: -I\${includedir}
EOF
    else
        echo "Target not supported"
        return -1
    fi

    cd ..
    rm -rf vulkan
}

ffbuild_configure() {
    echo --enable-vulkan
}

ffbuild_unconfigure() {
    echo --disable-vulkan
}
