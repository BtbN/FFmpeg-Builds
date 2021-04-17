FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

RUN \
    apt-get -y update && \
    apt-get -y dist-upgrade && \
    apt-get -y install build-essential yasm nasm xxd pkgconf git curl wget cmake unzip subversion autoconf automake libtool autopoint cmake clang texinfo texi2html gperf gettext itstool ragel libc6-dev libssl-dev gtk-doc-tools gobject-introspection gawk meson ninja-build p7zip-full python3-distutils python3-apt python-is-python3 && \
    apt-get -y clean

RUN git config --global user.email "builder@localhost" && \
    git config --global user.name "Builder"

ENV CARGO_HOME="/opt/cargo" RUSTUP_HOME="/opt/rustup" PATH="/opt/cargo/bin:${PATH}"
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y --no-modify-path
RUN cargo install cargo-c && rm -rf "${CARGO_HOME}"/{registry,git}

ADD run_stage.sh /usr/bin/run_stage
ADD git-mini-clone.sh /usr/bin/git-mini-clone
ADD check-wget.sh /usr/bin/check-wget
