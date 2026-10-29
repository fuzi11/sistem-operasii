
#!/bin/bash
set -e
cd /sources/texinfo-7.3

./configure --prefix=/usr
make
make check
make install

echo "Texinfo selesai."
