#!/bin/bash
set -e

cd /sources
tar -xf bash-5.3.tar.gz
cd bash-5.3

time {
  ./configure --prefix=$LFS/tools \
              --host=$LFS_TGT \
              --build=$(build-aux/config.guess) \
              --without-bash-malloc \
  && make \
  && make install \
  && ln -sfv bash $LFS/tools/bin/sh
}

cd /sources
rm -rf bash-5.3