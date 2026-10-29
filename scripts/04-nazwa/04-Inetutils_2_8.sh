#!/bin/bash
set -e

echo "Mulai instalasi Inetutils-2.8..."

cd /sources
tar -xf inetutils-2.8.tar.gz
cd inetutils-2.8

sed -i 's/def HAVE_TERMCAP_TGETENT/ 1/' telnet/telnet.c

./configure --prefix=/usr \
            --bindir=/usr/bin \
            --localstatedir=/var \
            --disable-logger \
            --disable-whois \
            --disable-rcp \
            --disable-rexec \
            --disable-rlogin \
            --disable-rsh \
            --disable-servers

make
make install

mv -v /usr/{,s}bin/ifconfig

cd /sources
rm -rf inetutils-2.8

echo "Instalasi Inetutils-2.8 selesai!"