#!/bin/bash
set -e

cd /sources
tar -xf m4-1.4.21.tar.xz
cd m4-1.4.21

time {
  ./configure --prefix=$LFS/tools \
              --host=$LFS_TGT \
              --build=$(build-aux/config.guess) \
  && make \
  && make install
}

cd /sources
rm -rf m4-1.4.21