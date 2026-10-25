#!/bin/bash
set -e

cd $LFS/sources
tar -xf grep-*.tar.*
cd grep-*

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)

make
make DESTDIR=$LFS install

cd $LFS/sources
rm -rf grep-*