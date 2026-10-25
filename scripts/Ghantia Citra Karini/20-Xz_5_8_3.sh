#!/bin/bash
set -e

cd /sources
tar -xf xz-5.8.3.tar.xz
cd xz-5.8.3

time {
  ./configure --prefix=$LFS/tools \
              --host=$LFS_TGT \
              --build=$(build-aux/config.guess) \
              --disable-static \
              --docdir=/usr/share/doc/xz-5.8.3 \
  && make \
  && make install
}

cd /sources
rm -rf xz-5.8.3
