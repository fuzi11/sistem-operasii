#!/bin/bash
set -e

cd /sources
tar -xf file-5.48.tar.gz
cd file-5.48

mkdir -v build
pushd build
  ../configure --disable-bzlib \
               --disable-libseccomp \
               --disable-xzlib \
               --disable-zlib
  make
popd

time {
  ./configure --prefix=$LFS/tools \
              --host=$LFS_TGT \
              --build=$(build-aux/config.guess) \
  && make FILE_COMPILE=$(pwd)/build/src/file \
  && make install
}

cd /sources
rm -rf file-5.48