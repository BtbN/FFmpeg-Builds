#!/bin/bash
# Common build helper functions to reduce code duplication across build scripts

# Validates target and adds toolchain configuration to myconf array
# Usage: validate_target_and_configure myconf
# Expects: TARGET variable to be set
# Modifies: The array whose name is passed as first parameter
validate_target_and_configure() {
    local -n conf_array=$1

    if [[ $TARGET == win* || $TARGET == linux* ]]; then
        conf_array+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return 1
    fi

    return 0
}

# Standard autotools build pattern
# Usage: build_autotools [configure_options...]
# Expects: Current directory to contain configure script
build_autotools() {
    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --with-pic
    )

    # Add any extra options passed as arguments
    myconf+=("$@")

    # Add target-specific configuration
    if ! validate_target_and_configure myconf; then
        return 1
    fi

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install DESTDIR="$FFBUILD_DESTDIR"
}

# Standard autotools build with autogen
# Usage: build_autotools_autogen [autogen_options] -- [configure_options...]
build_autotools_autogen() {
    local autogen_opts=()
    local configure_opts=()
    local found_separator=0

    # Parse arguments: everything before -- goes to autogen, after goes to configure
    while [[ $# -gt 0 ]]; do
        if [[ "$1" == "--" ]]; then
            found_separator=1
            shift
            configure_opts=("$@")
            break
        fi
        autogen_opts+=("$1")
        shift
    done

    # Run autogen if options provided
    if [[ ${#autogen_opts[@]} -gt 0 ]]; then
        ./autogen.sh "${autogen_opts[@]}"
    fi

    # Run standard autotools build
    build_autotools "${configure_opts[@]}"
}

# Standard CMake build pattern
# Usage: build_cmake [cmake_options...]
# Expects: Current directory to contain CMakeLists.txt
build_cmake() {
    mkdir -p build && cd build

    local myconf=(
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN"
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX"
        -DENABLE_SHARED=OFF
        -DBUILD_SHARED_LIBS=OFF
        -DENABLE_STATIC=ON
    )

    # Add any extra options passed as arguments
    myconf+=("$@")

    cmake "${myconf[@]}" ..
    make -j$(nproc)
    make install DESTDIR="$FFBUILD_DESTDIR"
}

# Standard Meson build pattern
# Usage: build_meson [meson_options...]
# Expects: Current directory to contain meson.build
build_meson() {
    mkdir -p build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=static
    )

    # Add cross-compilation file if needed
    if [[ $TARGET == win* || $TARGET == linux* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return 1
    fi

    # Add any extra options passed as arguments
    myconf+=("$@")

    meson setup "${myconf[@]}" ..
    ninja -j$(nproc)
    DESTDIR="$FFBUILD_DESTDIR" ninja install
}

# Extract script name from path (replaces basename | sed pattern)
# Usage: script_name=$(get_script_name "$SCRIPT_PATH")
get_script_name() {
    local path="$1"
    local name="${path##*/}"
    echo "${name%.sh}"
}

# Docker UID/TTY detection (shared between build.sh and download.sh)
# Usage: setup_docker_env
# Sets: UIDARGS and TTY_ARG global arrays/variables
setup_docker_env() {
    if docker info -f "{{println .SecurityOptions}}" | grep rootless &>/dev/null; then
        UIDARGS=()
    else
        UIDARGS=( -u "$(id -u):$(id -g)" )
    fi

    [[ -t 1 ]] && TTY_ARG="-t" || TTY_ARG=""
}

# Normalize whitespace in flags (replaces xargs usage)
# Usage: normalized=$(normalize_flags "$FF_CFLAGS")
normalize_flags() {
    local input="$1"
    # Trim leading and trailing whitespace, collapse internal whitespace
    echo "$input" | xargs
}

# Extract first field from output (replaces cut -d" " -f1 pattern)
# Usage: first=$(first_field "hash abc123 filename")
first_field() {
    local input="$1"
    echo "${input%% *}"
}

# Generate standard ffbuild_configure function output
# Usage: ffbuild_configure() { echo $(ffbuild_enable libname); }
# Or for multiple flags: ffbuild_configure() { echo $(ffbuild_enable libname) --other-flag; }
ffbuild_enable() {
    echo "--enable-$1"
}

# Generate standard ffbuild_unconfigure function output
# Usage: ffbuild_unconfigure() { echo $(ffbuild_disable libname); }
ffbuild_disable() {
    echo "--disable-$1"
}

# Add libraries to pkg-config Libs.private field
# Usage: add_pkgconfig_libs_private packagename lib1 lib2 lib3
add_pkgconfig_libs_private() {
    local pkgname="$1"
    shift
    local libs=""
    for lib in "$@"; do
        libs+=" -l$lib"
    done
    echo "Libs.private:$libs" >> "$FFBUILD_DESTPREFIX/lib/pkgconfig/${pkgname}.pc"
}

# Add flags to pkg-config Cflags.private field
# Usage: add_pkgconfig_cflags_private packagename flag1 flag2
add_pkgconfig_cflags_private() {
    local pkgname="$1"
    shift
    local flags="$*"
    echo "Cflags.private: $flags" >> "$FFBUILD_DESTPREFIX/lib/pkgconfig/${pkgname}.pc"
}

# Add raw line to pkg-config file
# Usage: add_pkgconfig_line packagename "Requires.private: zlib"
add_pkgconfig_line() {
    local pkgname="$1"
    local line="$2"
    echo "$line" >> "$FFBUILD_DESTPREFIX/lib/pkgconfig/${pkgname}.pc"
}

# Standard make build pattern (for projects without autotools/cmake/meson)
# Usage: build_make [make_options...]
build_make() {
    make -j$(nproc) "$@"
    make install DESTDIR="$FFBUILD_DESTDIR" "$@"
}

# Run autogen.sh if it exists
# Usage: run_autogen [autogen_options...]
run_autogen() {
    if [[ -f autogen.sh ]]; then
        ./autogen.sh "$@"
    elif [[ -f bootstrap ]]; then
        ./bootstrap "$@"
    fi
}
