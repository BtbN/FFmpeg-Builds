# FFmpeg Static Auto-Builds

Static Windows Builds of ffmpeg master and latest release branch.

## Auto-Builds

Builds run daily at 12:00 UTC and are automatically released on success.

## Package List

For a list of included dependencies check the scripts.d directory.
Every file corrosponds to its respective package.

## How to make a build

### Prerequisites

* bash
* docker

### Build Image

* `./makeimage.sh target variant [addins]`

### Build FFmpeg

* `./build.sh target variant [addins]`

On success, the resulting zip file will be in the `artifacts` subdir.

### Targets, Variants and Addins

The two available targets are `win64` and `win32`.

Available in `gpl`, `lgpl`, `gpl-shared` and `lgpl-shared` variants.

All of those can be optionally combined with any combination of addins.
Currently that's `4.3`, to build from the 4.3 release branch instead of master.
`vulkan` to add support for (and a hard runtime dependency on) Vulkan.
`debug` to not strip debug symbols from the binaries. This increases the output size by about 250MB.
