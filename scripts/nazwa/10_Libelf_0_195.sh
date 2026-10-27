```bash
#!/bin/bash
set -e

echo "Mulai instalasi Less-704..."

cd /sources
tar -xf less-704.tar.gz
cd less-704

./configure --prefix=/usr --sysconfdir=/etc

make
make check
make install

cd /sources
rm -rf less-704

echo "Instalasi Less-704 selesai!"
```