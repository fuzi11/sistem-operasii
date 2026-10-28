
#!/bin/bash
set -e
cd /sources/make-4.4.1

./configure --prefix=/usr
make
make check
make install

echo "Make selesai."
