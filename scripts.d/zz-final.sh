#!/bin/bash

SCRIPT_SKIP="1"

ffbuild_depends() {
    echo libiconv
    echo zlib
    echo fribidi
    echo gmp
    echo libxml2
    echo openssl
    echo xz
    echo fonts
    echo lcevcdec
    echo libvorbis
    echo opencl
    echo pulseaudio
    echo vmaf
    echo x11
    echo vulkan
    echo amf
    echo aom
    echo avisynth
    echo chromaprint
    echo dav1d
    echo davs2
    echo dvd
    echo fdk-aac
    echo ffnvcodec
    echo frei0r
    echo gme
    echo kvazaar
    echo libaribb24
    echo libaribcaption
    echo libass
    echo libbluray
    echo libbs2b
    echo libcurl
    echo libgsm
    echo libjxl
    echo libmp3lame
    echo libmysofa
    echo libopus
    echo libplacebo
    echo libpng
    echo librist
    echo librsvg
    echo libshine
    echo libspeex
    echo libssh
    echo libtheora
    echo libvpx
    echo libwebp
    echo libzmq
    echo lilv
    echo onevpl
    echo openal
    echo openapv
    echo opencore-amr
    echo openh264
    echo openjpeg
    echo openmpt
    echo rav1e
    echo rubberband
    echo rustdedup
    echo schannel
    echo sdl
    echo snappy
    echo soxr
    echo srt
    echo svtav1
    echo twolame
    echo uavs3d
    echo vaapi
    echo vidstab
    echo vvenc
    echo whisper
    echo x264
    echo x265
    echo xavs2
    echo xevd
    echo xeve
    echo xvid
    echo zimg
    echo zvbi
}

ffbuild_enabled() {
    return 0
}

ffbuild_dockerfinal() {
    return 0
}

ffbuild_dockerdl() {
    return 0
}

ffbuild_dockerlayer() {
    return 0
}

ffbuild_dockerstage() {
    return 0
}

ffbuild_dockerbuild() {
    return 0
}

ffbuild_ldexeflags() {
    return 0
}
