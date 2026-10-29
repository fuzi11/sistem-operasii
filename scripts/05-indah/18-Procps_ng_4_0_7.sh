
#!/bin/bash
set -e

cd /sources
tar -xf procps-ng-4.0.7.tar.xz
cd procps-ng-4.0.7

./configure --prefix=/usr \
    --docdir=/usr/share/doc/procps-ng-4.0.7 \
    --disable-static \
    --disable-kill \
    --enable-watch8bit \
    --with-systemd

make
make install

cd /sources
rm -rf procps-ng-4.0.7


echo "Procps-ng selesai."
