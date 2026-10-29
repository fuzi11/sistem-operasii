
#!/bin/bash
set -e

cd /sources
tar -xf gzip-1.14.tar.xz
cd gzip-1.14

./configure --prefix=/usr
make
make install

cd /sources
rm -rf gzip-1.14

echo "Gzip selesai."
