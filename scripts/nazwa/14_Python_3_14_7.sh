#!/bin/bash
set -e

cd /sources
tar -xf mpdecimal-4.0.1.tar.gz
cd mpdecimal-4.0.1

./configure --prefix=/usr --disable-static
make
make install

cd /sources
rm -rf mpdecimal-4.0.1