#!/bin/bash
set -e

cd /sources
tar -xf patch-2.8.tar.xz
cd patch-2.8

time {
  ./configure --prefix=$LFS/tools \
              --host=$LFS_TGT \
              --build=$(build-aux/config.guess) \
  && make \
  && make install
}

cd /sources
rm -rf patch-2.8