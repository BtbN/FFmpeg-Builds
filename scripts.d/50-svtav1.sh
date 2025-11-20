#!/bin/bash

<<<<<<< HEAD
SCRIPT_REPO="https://github.com/nekotrix/SVT-AV1-Essential.git"
SCRIPT_COMMIT="e9d30d710497a6757180cc3ae64d32550a298305"
SCRIPT_BRANCH="Essential-v3.1.2"
||||||| 73df4cc
SCRIPT_REPO="https://gitlab.com/AOMediaCodec/SVT-AV1.git"
SCRIPT_COMMIT="ce5dda77cb9767573c75779b2e22e7d621b02610"
=======
SCRIPT_REPO="https://gitlab.com/AOMediaCodec/SVT-AV1.git"
SCRIPT_COMMIT="f0057e34d1656fd2c1e1f349d8281459272cc5cb"
>>>>>>> b3ec4ea53f3aaec7eef1a5bbb8deb8d9a927494a

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
