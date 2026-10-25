#!/bin/bash
set -e

cd /sources
tar -xf coreutils-9.11.tar.xz
cd coreutils-9.11

time {
  ./configure --prefix=$LFS/tools \
              --host=$LFS_TGT \
              --build=$(build-aux/config.guess) \
              --enable-install-program=hostname \
              --enable-no-install-program=kill,uptime \
              gl_cv_macro_MB_CUR_MAX_good=yes \
  && make \
  && make install
}

cd /sources
rm -rf coreutils-9.11