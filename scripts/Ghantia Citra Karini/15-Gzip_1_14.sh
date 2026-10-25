#!/bin/bash
set -e

cd /sources
tar -xf gzip-1.14.tar.xz
cd gzip-1.14

time {
  ./configure --prefix=$LFS/tools \
              --host=$LFS_TGT \
  && make \
  && make install
}

cd /sources
rm -rf gzip-1.14
