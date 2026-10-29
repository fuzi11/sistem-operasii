#!/bin/bash
set -e

cd $LFS/sources
tar -xf diffutils-*.tar.*
cd diffutils-*

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            gl_cv_func_strcasecmp_works=yes \
            --build=$(./build-aux/config.guess)

make
make DESTDIR=$LFS install

cd $LFS/sources
rm -rf diffutils-*