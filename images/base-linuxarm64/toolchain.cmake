set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)
set(CMAKE_SYSTEM_VERSION 4.18.20)

set(triple aarch64-ffbuild-linux-gnu)

set(CMAKE_C_COMPILER ${triple}-gcc)
set(CMAKE_CXX_COMPILER ${triple}-g++)
set(CMAKE_RANLIB ${triple}-gcc-ranlib)
set(CMAKE_AR ${triple}-gcc-ar)

set(CMAKE_SYSROOT /opt/ct-ng/${triple}/sysroot)
set(CMAKE_FIND_ROOT_PATH /opt/ct-ng /opt/ct-ng/${triple}/sysroot /opt/ffbuild)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
