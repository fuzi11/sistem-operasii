
#!/bin/bash
set -e

cd /sources
tar -xf util-linux-2.42.2.tar.xz
cd util-linux-2.42.2

./configure --bindir=/usr/bin \
    --libdir=/usr/lib \
    --runstatedir=/run \
    --sbindir=/usr/sbin \
    --disable-chfn-chsh \
    --disable-login \
    --disable-nologin \
    --disable-su \
    --disable-setpriv \
    --disable-runuser \
    --disable-pylibmount \
    --disable-liblastlog2 \
    --disable-static \
    --without-python \
    ADJTIME_PATH=/var/lib/hwclock/adjtime \
    --docdir=/usr/share/doc/util-linux-2.42.2

make
make install

cd /sources
rm -rf util-linux-2.42.2

echo "Util-linux selesai."
