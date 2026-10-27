#!/bin/bash
set -e

cd /sources
tar -xf kmod-34.2.tar.xz
cd kmod-34.2

mkdir -p build
cd build

meson setup --prefix=/usr \
            --buildtype=release \
            -D manpages=false

ninja
ninja install

cd /sources
rm -rf kmod-34.2