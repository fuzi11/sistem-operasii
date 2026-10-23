#!/bin/bash
set -e

cd /sources
tar -xf openssl-4.0.1.tar.gz
cd openssl-4.0.1

./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib shared zlib-dynamic
make
make INSTALL_LIBS= MANSUFFIX=ssl install

mv -v /usr/share/doc/openssl /usr/share/doc/openssl-4.0.1
cp -vfr doc/* /usr/share/doc/openssl-4.0.1

cd /sources
rm -rf openssl-4.0.1