#### Language: [English](./README.md) | 简体中文
# FFmpeg 静态自动构建

静态编译的Windows（适用于x86_64架构）与Linux（适用于x86_64架构）系统上的ffmpeg主分支版及其最新发布的版本构建。

Windows版面向Windows7及更高版本。

Linux版针对 RHEL/CentOS 8 (基于glibc-2.28及更高版本，搭配linux-4.18内核) 及较新版本。

## 自动构建

每日 12:00 UTC（或 GitHub 对该时间的理解）自动构建并确保能成功运行。

**自动构建只适用于win64和linux(arm)64，没有win32/x86的自动构建，但你可以按照以下说明自己构建win32版。**

### 发行版本保留规则

- 每月最后一个版本会保留两年。
- 最近的14个每日构建版本会被保留。
-特定“最新版本”版会动态更新，始终提供最新版本的 URL 地址。

## 软件包列表

有关所含依赖项的详细列表，请查看scripts.d目录。
该目录下的每个文件均对应相应的软件包。

## 如何构建

### 必备条件

* bash
* docker

### 构建Docker镜像

* `./makeimage.sh target variant [addin [addin] [addin] ...]`

### 构建FFmpeg

* `./build.sh target variant [addin [addin] [addin] ...]`

在构建成功后，生成的zip压缩包将放在`artifacts`目录下。

### 目标体系、版本分支和附加组件

可用目标：
* `win64` (x86_64)
* `win32` (x86)
* `linux64` (x86_64 Linux, glibc>=2.28, linux>=4.18)
* `linuxarm64` (arm64 (aarch64) Linux, glibc>=2.28, linux>=4.18)

鉴于当前存在对arm64（即aarch64架构）硬件支持不足或交叉编译条件限制的问题，导致在构建linuxarm64版时，某些依赖组件无法成功编译生成。

* `davs2` and `xavs2`: 当前不支持aarch64架构
* `libmfx` and `libva`: 这两个库主要用于配合英特尔Quick Sync Video加速技术，目前并不支持aarch64架构，因此在构建linuxarm64目标时，它们无法针对arm64架构进行编译

可用版本分支：
* `gpl` 包含所有依赖项，即使那些仅需GPL而非LGPL许可的依赖项也会包含在内。
* `lgpl` 缺少仅 GPL 的库。最显着的是 libx264 和 libx265。
* `nonfree` 除了包含gpl变体的所有依赖项之外，还额外包含了fdk-aac非自由软件库。
* `gpl-shared` 与 gpl 相同，但附带共享库的 libav* 系列而不是纯静态可执行文件。
* `lgpl-shared` 同样采用lgpl许可依赖项集，但提供的是共享库形式。
* `nonfree-shared` 再次包含了开源软件依赖项集，并提供的是共享库形式。

以上所有变体均可按需与任意组合的插件共同使用：
* `4.4`/`5.0`/`5.1`/`6.0` 选择这些选项可在相应发布分支而非master分支上进行构建。
* `debug` 保留二进制文件中的调试符号，不进行剥离操作，但这样会导致输出文件大小增加约250MB。
* `lto` 使用 -flto=auto 生成所有依赖项和 ffmpeg（高度实验性功能，对于Windows系统可能会存在问题，但在某些情况下对Linux系统有效）
