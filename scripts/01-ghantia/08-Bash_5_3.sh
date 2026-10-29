#!/bin/bash
set -e

cd $LFS/sources
tar -xf bash-*.tar.*
cd bash-*

./configure --prefix=/usr                      \
            --build=$(sh support/config.guess) \
            --host=$LFS_TGT                    \
            --without-bash-malloc              \
            --docdir=/usr/share/doc/bash-5.3

make
make DESTDIR=$LFS install

ln -sv bash $LFS/bin/sh

cd $LFS/sources
rm -rf bash-*