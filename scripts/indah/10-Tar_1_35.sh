
#!/bin/bash
set -e
cd /sources/tar-1.35

patch -Np1 -i ../tar-1.35-acl_fix-1.patch

FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr
make
make check
make install

echo "Tar selesai."
