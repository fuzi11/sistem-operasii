
#!/bin/bash
set -e
cd /sources
tar -xf tar-1.35.tar.xz
cd tar-1.35

patch -Np1 -i ../tar-1.35-acl_fix-1.patch

FORCE_UNSAFE_CONFIGURE=1 \
./configure --prefix=/usr

make
make install
make -C doc install-html docdir=/usr/share/doc/tar-1.35

cd /sources
rm -rf tar-1.35

echo "Tar selesai."
