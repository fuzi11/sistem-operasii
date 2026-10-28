
#!/bin/bash
set -e
cd /sources/e2fsprogs-1.47.4

mkdir -p build
cd build

../configure --prefix=/usr \
    --sysconfdir=/etc \
    --enable-elf-shlibs \
    --disable-libblkid \
    --disable-libuuid \
    --disable-uuidd \
    --disable-fsck

make
make check
make install
make install-libs

echo "E2fsprogs selesai."
