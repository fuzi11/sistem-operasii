#!/bin/bash
set -e

cd /sources
tar -xf autoconf-2.73.tar.xz
cd autoconf-2.73

./configure --prefix=/usr
make
make install

cd /sources
rm -rf autoconf-2.73