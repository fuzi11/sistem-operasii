#!/bin/bash
set -e

cd /sources
tar -xf binutils-2.47.tar.xz
cd binutils-2.47

sed -i '/@select_fill/d' lexer.l

mkdir -v build
cd build

time {
  ../configure \
    --prefix=$LFS/tools \
    --build=$(../config.guess) \
    --host=$LFS_TGT \
    --disable-nls \
    --enable-shared \
    --enable-gprofng=no \
    --disable-werror \
    --enable-64-bit-bfd \
    --enable-new-dtags \
    --enable-default-hash-style=gnu \
    && make \
    && make install
}

cd /sources
rm -rf binutils-2.47
