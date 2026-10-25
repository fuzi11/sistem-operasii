#!/bin/bash
set -e

cd /sources
tar -xf tar-1.35.tar.xz
cd tar-1.35

time {
  ./configure --prefix=$LFS/tools \
              --host=$LFS_TGT \
              --build=$(build-aux/config.guess) \
  && make \
  && make install
}

cd /sources
rm -rf tar-1.35
