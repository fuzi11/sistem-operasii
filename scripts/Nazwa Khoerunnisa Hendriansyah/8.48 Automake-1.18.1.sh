```bash
#!/bin/bash
set -e

echo "Mulai instalasi Automake-1.18.1..."

cd /sources
tar -xf automake-1.18.1.tar.xz
cd automake-1.18.1

./configure --prefix=/usr \
            --docdir=/usr/share/doc/automake-1.18.1

make

make -j$(($(nproc)>4?$(nproc):4)) check

make install

cd /sources
rm -rf automake-1.18.1

echo "Instalasi Automake-1.18.1 selesai!"
```