# FFmpeg Static Auto-Builds
<div align=center>

[![windows autobuild architecture](https://img.shields.io/badge/Architecture-Windows%20x86__64-blue?logo=windows&style=for-the-badge)](https://github.com/BtbN/FFmpeg-Builds/wiki/Latest) [![linux autobuild architecture](https://img.shields.io/badge/Architecture-Linux%20x86__64-blue?logo=linux&style=for-the-badge)](https://github.com/BtbN/FFmpeg-Builds/wiki/Latest) [![GitHub all releases](https://img.shields.io/github/downloads/BtbN/FFmpeg-Builds/total?style=for-the-badge)](https://github.com/BtbN/FFmpeg-Builds/releases) [![GitHub release (latest by date)](https://img.shields.io/github/v/release/BtbN/FFmpeg-Builds?style=for-the-badge&color=ff0066)](https://github.com/BtbN/FFmpeg-Builds/releases/latest) [![GitHub issues](https://img.shields.io/github/issues/BtbN/FFmpeg-Builds?style=for-the-badge&color=red)](https://github.com/BtbN/FFmpeg-Builds/issues?q=is%3Aopen+is%3Aissue) [![closed issues](https://img.shields.io/github/issues-closed/BtbN/FFmpeg-Builds?style=for-the-badge)](https://github.com/BtbN/FFmpeg-Builds/issues?q=is%3Aissue+is%3Aclosed)

</div>
Static Windows (x86_64) and Linux (x86_64) Builds of ffmpeg master and latest release branch.

Windows builds are targetting Windows 7 and newer.

Linux builds are targetting Ubuntu 16.04 (glibc-2.23 + linux-4.4) and anything more recent.

## Auto-Builds

Builds run daily at 12:00 UTC (or GitHubs idea of that time) and are automatically released on success.

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

Available targets:
* win64 (x86_64 Windows)
* win32 (x86 Windows)
* linux64 (x86_64 Linux, glibc>=2.23, linux>=4.4)

Available:
* `gpl`
* `lgpl`
* `gpl-shared`
* `lgpl-shared`

All of those can be optionally combined with any combination of addins.
* `4.4` to build from the 4.4 release branch instead of master.
* `debug` to not strip debug symbols from the binaries. This increases the output size by about 250MB.
