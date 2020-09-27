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

* `./makeimage.sh win64 gpl`

### Build FFmpeg

* `./build.sh win64 gpl`

On success, the resulting zip file will be in the `artifacts` subdir.
