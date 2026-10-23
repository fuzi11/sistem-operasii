```bash
#!/bin/bash
set -e

echo "Mulai instalasi Autoconf-2.73..."

cd /sources
tar -xf autoconf-2.73.tar.xz
cd autoconf-2.73

./configure --prefix=/usr

make
make check
make install

cd /sources
rm -rf autoconf-2.73

echo "Instalasi Autoconf-2.73 selesai!"
```