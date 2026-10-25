#!/bin/bash
set -e

cd /sources
tar -xf findutils-4.11.0.tar.xz
cd findutils-4.11.0

time {
  ./configure --prefix=$LFS/tools \
              --localstatedir=$LFS/var/lib/locate \
              --host=$LFS_TGT \
              --build=$(build-aux/config.guess) \
  && make \
  && make install
}

cd /sources
rm -rf findutils-4.11.0