
#!/bin/bash
set -e

cd /sources
tar -xf kbd-2.10.0.tar.xz
cd kbd-2.10.0

patch -Np1 -i ../kbd-2.10.0-backspace-1.patch

sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in

./configure --prefix=/usr --disable-vlock
make
make install

cp -R -v docs/doc -T /usr/share/doc/kbd-2.10.0

cd /sources
rm -rf kbd-2.10.0

echo "Kbd selesai."
