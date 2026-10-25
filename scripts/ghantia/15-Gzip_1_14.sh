#!/bin/bash
set -e

cd $LFS/sources
tar -xf gzip-*.tar.*
cd gzip-*

./configure --prefix=/usr --host=$LFS_TGT

make
make DESTDIR=$LFS install

cd $LFS/sources
rm -rf gzip-*