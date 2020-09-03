FROM btbn/ffmpeg-builder:base

ENV DEBIAN_FRONTEND noninteractive

RUN \
    apt-get -y install mingw-w64 && \
    apt-get -y clean

ENV FFBUILD_TARGET_FLAGS "--pkg-config=pkg-config --cross-prefix=x86_64-w64-mingw32- --arch=x86_64 --target-os=win32"
ENV FFBUILD_TOOLCHAIN x86_64-w64-mingw32
ENV FFBUILD_CROSS_PREFIX x86_64-w64-mingw32-
