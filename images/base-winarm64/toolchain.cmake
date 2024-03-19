set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

set(triple aarch64-w64-mingw32)

set(CMAKE_C_COMPILER ${triple}-clang)
set(CMAKE_CXX_COMPILER ${triple}-clang++)
set(CMAKE_RC_COMPILER ${triple}-windres)
set(CMAKE_RANLIB ${triple}-llvm-ranlib)
set(CMAKE_AR ${triple}-llvm-ar)

set(CMAKE_SYSROOT /opt/llvm-mingw/${triple})
set(CMAKE_FIND_ROOT_PATH /opt/llvm-mingw /opt/llvm-mingw/${triple} /opt/ffbuild)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
