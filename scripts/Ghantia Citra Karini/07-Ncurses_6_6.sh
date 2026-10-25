#!/bin/bash
set -e

cd /sources
tar -xf ncurses-6.6.tar.gz
cd ncurses-6.6

sed -i s/mawk// configure

mkdir -v build
pushd build
  ../configure
  make -C include
  make -C progs tic
popd

time {
  ./configure --prefix=$LFS/tools \
              --host=$LFS_TGT \
              --build=$(build-aux/config.guess) \
              --mandir=$LFS/tools/share/man \
              --with-shared \
              --without-debug \
              --without-ada \
              --without-normal \
              --enable-widec \
  && make \
  && make TIC_PATH=$(pwd)/build/progs/tic install \
  && echo "INPUT(-lncursesw)" > $LFS/tools/lib/libncurses.so
}

cd /sources
rm -rf ncurses-6.6