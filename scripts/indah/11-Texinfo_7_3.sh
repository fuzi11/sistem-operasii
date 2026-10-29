
#!/bin/bash
set -e

cd /sources
tar -xf texinfo-7.3.tar.xz
cd texinfo-7.3

./configure --prefix=/usr
make
make install
make TEXMF=/usr/share/texmf install-tex

cd /sources
rm -rf texinfo-7.3

echo "Texinfo selesai."
