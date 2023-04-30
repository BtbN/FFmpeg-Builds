set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR i686)

set(triple i686-w64-mingw32)

set(CMAKE_C_COMPILER ${triple}-gcc)
set(CMAKE_CXX_COMPILER ${triple}-g++)
set(CMAKE_RC_COMPILER ${triple}-windres)
set(CMAKE_RANLIB ${triple}-gcc-ranlib)
set(CMAKE_AR ${triple}-gcc-ar)

set(CMAKE_SYSROOT /opt/ct-ng/${triple}/sysroot)
set(CMAKE_FIND_ROOT_PATH /opt/ct-ng /opt/ct-ng/${triple}/sysroot /opt/ffbuild)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
