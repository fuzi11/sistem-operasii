#!/bin/bash
set -e

cd /sources
tar -xf grep-3.12.tar.xz
cd grep-3.12

time {
  ./configure --prefix=$LFS/tools \
              --host=$LFS_TGT \
              --build=$(build-aux/config.guess) \
  && make \
  && make install
}

cd /sources
rm -rf grep-3.12
