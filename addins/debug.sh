#!/usr/bin/env bash
FF_CONFIGURE="${FF_CONFIGURE/--disable-debug/} --optflags='-Og' --disable-stripping"
