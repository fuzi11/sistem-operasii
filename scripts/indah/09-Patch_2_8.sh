
#!/bin/bash
set -e
cd /sources/patch-2.8

./configure --prefix=/usr
make
make check
make install

echo "Patch selesai."
