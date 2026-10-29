#!/bin/bash
set -e

cd $LFS/sources
tar -xf findutils-*.tar.*
cd findutils-*

./configure --prefix=/usr                   \
            --localstatedir=/var/lib/locate \
            --host=$LFS_TGT                 \
            --build=$(build-aux/config.guess)

make
make DESTDIR=$LFS install

cd $LFS/sources
rm -rf findutils-*