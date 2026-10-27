#!/bin/bash
set -e

echo "Mulai instalasi mpdecimal-4.0.1..."

cd /sources
tar -xf mpdecimal-4.0.1.tar.gz
cd mpdecimal-4.0.1

./configure --prefix=/usr \
            --disable-static \
            --docdir=/usr/share/doc/mpdecimal-4.0.1

make
make install

cd /sources
rm -rf mpdecimal-4.0.1

echo "Instalasi mpdecimal-4.0.1 selesai!"