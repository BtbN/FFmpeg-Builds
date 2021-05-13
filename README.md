# FFmpeg Static Auto-Builds

Static Windows Builds of ffmpeg master and latest release branch.

EXPERIMENTAL Linux-Builds. Do not expect everything to work on them, specially anything that involves loading dynamic libs at runtime.
Shared Linux builds need musl installed to run the programs. YMMV when trying to use the libraries.
Please report any issues you encounter with those builds!

## Auto-Builds

Builds run daily at 12:00 UTC and are automatically released on success.

### Release Retention Policy

- The last build of each month is kept for two years.
- The last 14 daily builds are kept.

## Package List

For a list of included dependencies check the scripts.d directory.
Every file corresponds to its respective package.

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
Currently that's `4.4`, to build from the 4.4 release branch instead of master.
`debug` to not strip debug symbols from the binaries. This increases the output size by about 250MB.
