#!/bin/bash
set -e

cd /sources
tar -xf Python-3.14.7.tar.xz
cd Python-3.14.7

./configure --prefix=/usr --enable-shared --with-system-expat --enable-optimizations
make
make install

install -v -dm755 /usr/share/doc/python-3.14.7/html
tar --no-same-owner -xvf ../python-3.14.7-docs-html.tar.bz2
cp -R --no-preserve=mode python-3.14.7-docs-html/* /usr/share/doc/python-3.14.7/html

cd /sources
rm -rf Python-3.14.7