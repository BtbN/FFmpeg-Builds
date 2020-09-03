FROM btbn/ffmpeg-builder:base

ENV DEBIAN_FRONTEND noninteractive

RUN \
    apt-get -y install mingw-w64 && \
    apt-get -y clean && \
    rm /usr/lib/gcc/*-w64-mingw32/*/libstdc++*.dll* && \
    rm /usr/lib/gcc/*-w64-mingw32/*/libgcc_s* && \
    mkdir /opt/ffbuild

ADD toolchain.cmake /toolchain.cmake

ENV FFBUILD_TARGET_FLAGS="--pkg-config=pkg-config --cross-prefix=x86_64-w64-mingw32- --arch=x86_64 --target-os=mingw32" \
    FFBUILD_TOOLCHAIN=x86_64-w64-mingw32 \
    FFBUILD_CROSS_PREFIX=x86_64-w64-mingw32- \
    FFBUILD_PREFIX=/opt/ffbuild \
    FFBUILD_CMAKE_TOOLCHAIN=/toolchain.cmake \
    PKG_CONFIG_LIBDIR=/opt/ffbuild/lib/pkgconfig \
    CFLAGS="-static-libgcc -static-libstdc++" \
    CXXFLAGS="-static-libgcc -static-libstdc++" \
    LDFLAGS="-static-libgcc -static-libstdc++"
