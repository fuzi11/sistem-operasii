
#!/bin/bash
set -e
cd /sources
tar -xf make-4.4.1.tar.gz
cd make-4.4.1

./configure --prefix=/usr
make
make install

cd /sources
rm -rf make-4.4.1

echo "Make selesai."
