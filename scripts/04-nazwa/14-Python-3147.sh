#!/bin/bash
set -e

echo "Mulai instalasi Python-3.14.7..."

cd /sources
tar -xf Python-3.14.7.tar.xz
cd Python-3.14.7

patch -Np1 -i ../Python-3.14.7-openssl_4-1.patch

./configure --prefix=/usr \
            --enable-shared \
            --with-system-expat \
            --enable-optimizations \
            --without-static-libpython

make
make install

cat > /etc/pip.conf << EOF
[global]
root-user-action = ignore
disable-pip-version-check = true
EOF

install -v -dm755 /usr/share/doc/python-3.14.7/html

tar --strip-components=1 \
    --no-same-owner \
    --no-same-permissions \
    -C /usr/share/doc/python-3.14.7/html \
    -xvf ../python-3.14.7-docs-html.tar.bz2

cd /sources
rm -rf Python-3.14.7

echo "Instalasi Python-3.14.7 selesai!"