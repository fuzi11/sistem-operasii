
#!/bin/bash
set -e
cd /sources/gzip-1.14

./configure --prefix=/usr
make
make check
make install

echo "Gzip selesai."
