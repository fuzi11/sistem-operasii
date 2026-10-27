#!/bin/bash
set -e

cd /sources
tar -xf perl-5.44.0.tar.xz
cd perl-5.44.0

export BUILD_ZLIB=False
export BUILD_BZIP2=0

sh Configure -des -Dprefix=/usr -Dvendorprefix=/usr -Duseshrplib -Dusethreads
make
make install

unset BUILD_ZLIB
unset BUILD_BZIP2

cd /sources
rm -rf perl-5.44.0