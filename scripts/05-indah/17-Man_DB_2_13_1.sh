
#!/bin/bash
set -e

cd /sources
tar -xf man-db-2.13.1.tar.xz
cd man-db-2.13.1

./configure --prefix=/usr \
    --docdir=/usr/share/doc/man-db-2.13.1 \
    --sysconfdir=/etc \
    --disable-setuid \
    --enable-cache-owner=bin \
    --with-browser=/usr/bin/lynx \
    --with-vgrind=/usr/bin/vgrind \
    --with-grap=/usr/bin/grap

make
make install

cd /sources
rm -rf man-db-2.13.1

echo "Man-DB selesai."
