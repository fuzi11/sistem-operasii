#!/bin/bash
set -e

cd /sources
tar -xf elfutils-0.195.tar.bz2
cd elfutils-0.195

./configure --prefix=/usr --disable-debuginfod --enable-libdebuginfod=dummy
make
make -C libelf install
install -vm644 config/libelf.pc /usr/lib/pkgconfig

cd /sources
rm -rf elfutils-0.195