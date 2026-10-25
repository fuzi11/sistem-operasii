#!/bin/bash
set -e

cd /sources
tar -xf sed-4.10.tar.xz
cd sed-4.10

time {
  ./configure --prefix=$LFS/tools \
              --host=$LFS_TGT \
              --build=$(build-aux/config.guess) \
  && make \
  && make install
}

cd /sources
rm -rf sed-4.10