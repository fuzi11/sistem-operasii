
#!/bin/bash
set -e
cd /sources/findutils-4.11.0

./configure --prefix=/usr \
            --localstatedir=/var/lib/locate
make
make check
make install

echo "Findutils selesai."
