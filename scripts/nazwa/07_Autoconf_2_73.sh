#!/bin/bash
set -e

cd /sources
tar -xf diffutils-3.12.tar.xz
cd diffutils-3.12

./configure --prefix=/usr
make
make install

cd /sources
rm -rf diffutils-3.12