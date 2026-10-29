#!/bin/bash
set -e

cd /sources
tar -xf findutils-4.11.0.tar.xz
cd findutils-4.11.0

./configure --prefix=/usr \
            --localstatedir=/var/lib/locate
make
make install

cd /sources
rm -rf findutils-4.11.0

echo "Findutils selesai."
