
#!/bin/bash
set -e
cd /sources/groff-1.24.1

PAGE=A4 ./configure --prefix=/usr
make -j1
make install

echo "Groff selesai."
