#!/bin/bash
set -e

cd /sources
tar -xf libffi-3.8.0.tar.gz
cd libffi-3.8.0

./configure --prefix=/usr --disable-static --with-gcc-arch=native
make
make install

cd /sources
rm -rf libffi-3.8.0