```bash
#!/bin/bash
set -e

echo "Mulai instalasi Libffi-3.8.0..."

cd /sources
tar -xf libffi-3.8.0.tar.gz
cd libffi-3.8.0

./configure --prefix=/usr \
            --disable-static \
            --with-gcc-arch=native

make
make check
make install

cd /sources
rm -rf libffi-3.8.0

echo "Instalasi Libffi-3.8.0 selesai!"
```