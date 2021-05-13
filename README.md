# FFmpeg Static Auto-Builds

![Build FFmpeg](https://github.com/sudo-nautilus/FFmpeg-Builds-Win32/actions/workflows/build.yml/badge.svg)
[![Percentage of issues still open](http://isitmaintained.com/badge/open/sudo-nautilus/FFmpeg-Builds-Win32.svg)](http://isitmaintained.com/project/sudo-nautilus/FFmpeg-Builds-Win32 "Percentage of issues still open")
[![Average time to resolve an issue](http://isitmaintained.com/badge/resolution/sudo-nautilus/FFmpeg-Builds-Win32.svg)](http://isitmaintained.com/project/sudo-nautilus/FFmpeg-Builds-Win32 "Average time to resolve an issue")

Static 32 bit Windows Builds of ffmpeg master and latest release branch. This repository is forked and well maintained. For static 64 bit Windows FFmpeg builds, you can check [BtbN's repository](https://github.com/BtbN/FFmpeg-Builds). Go to Wiki tab or go to releases for downloads.

EXPERIMENTAL Linux-Builds. Do not expect everything to work on them, specially anything that involved loading dynamic libs at runtime.
Shared Linux builds come without the programs (hopefully just for now), since they won't run without musl.

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
