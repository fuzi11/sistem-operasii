
#!/bin/bash
set -e
cd /sources/libpipeline-1.5.8

./configure --prefix=/usr
make
make install

echo "Libpipeline selesai."
