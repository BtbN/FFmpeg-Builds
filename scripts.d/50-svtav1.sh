#!/bin/bash

SCRIPT_REPO="https://gitlab.com/AOMediaCodec/SVT-AV1.git"
SCRIPT_COMMIT="f0057e34d1656fd2c1e1f349d8281459272cc5cb"

ffbuild_enabled(){
  [[ $TARGET == win32 ]] && return -1
  (( $(ffbuild_ffver) > 700 )) || return -1; return 0  
}
ffbuild_dockerdl(){ echo "git clone \"$SCRIPT_REPO\" . && git checkout \"$SCRIPT_COMMIT\""; }

ffbuild_dockerbuild() {
    build_cmake -DBUILD_TESTING=OFF -DBUILD_APPS=OFF -DENABLE_AVX512=ON -DSVT_AV1_LTO=OFF
}

ffbuild_configure() {
    echo $(ffbuild_enable libsvtav1)
}

ffbuild_unconfigure() {
    echo $(ffbuild_disable libsvtav1)
}
