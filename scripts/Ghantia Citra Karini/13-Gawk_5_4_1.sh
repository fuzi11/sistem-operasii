#!/bin/bash
set -e

cd /sources
tar -xf gawk-5.4.1.tar.xz
cd gawk-5.4.1

sed -i 's/extras//' Makefile.in

time {
  ./configure --prefix=$LFS/tools \
              --host=$LFS_TGT \
              --build=$(build-aux/config.guess) \
  && make \
  && make install
}

cd /sources
rm -rf gawk-5.4.1