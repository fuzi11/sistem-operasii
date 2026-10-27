```bash
#!/bin/bash
set -e

echo "Mulai instalasi Gperf-3.3..."

cd /sources

tar -xf gperf-3.3.tar.gz
cd gperf-3.3

./configure --prefix=/usr \
            --docdir=/usr/share/doc/gperf-3.3

make

make check

make install

cd /sources
rm -rf gperf-3.3

echo "Instalasi Gperf-3.3 selesai!"
```