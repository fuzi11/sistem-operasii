#!/bin/bash
set -e

cd /sources
tar -xf make-4.4.1.tar.gz
cd make-4.4.1

time {
  ./configure --prefix=$LFS/tools \
              --without-guile \
              --host=$LFS_TGT \
              --build=$(build-aux/config.guess) \
  && make \
  && make install
}

cd /sources
rm -rf make-4.4.1
