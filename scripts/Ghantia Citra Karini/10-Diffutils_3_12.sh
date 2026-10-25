#!/bin/bash
set -e

cd /sources
tar -xf diffutils-3.12.tar.xz
cd diffutils-3.12

time {
  ./configure --prefix=$LFS/tools \
              --host=$LFS_TGT \
              --build=$(build-aux/config.guess) \
  && make \
  && make install
}

cd /sources
rm -rf diffutils-3.12