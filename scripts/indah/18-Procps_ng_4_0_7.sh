
#!/bin/bash
set -e
cd /sources/procps-ng-4.0.7

./configure --prefix=/usr \
    --docdir=/usr/share/doc/procps-ng-4.0.7 \
    --disable-static \
    --disable-kill \
    --enable-watch8bit \
    --with-systemd

make
make check
make install

echo "Procps-ng selesai."
