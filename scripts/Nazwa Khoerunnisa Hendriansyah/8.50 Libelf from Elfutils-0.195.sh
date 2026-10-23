```bash
#!/bin/bash
set -e

echo "Mulai instalasi Libelf dari Elfutils-0.195..."

cd /sources
tar -xf elfutils-0.195.tar.bz2
cd elfutils-0.195

./configure --prefix=/usr \
            --disable-debuginfod \
            --enable-libdebuginfod=dummy

make -C lib
make -C libelf

make -k check

make -C libelf install

install -vm644 config/libelf.pc /usr/lib/pkgconfig

rm -f /usr/lib/libelf.a

cd /sources
rm -rf elfutils-0.195

echo "Instalasi Libelf-0.195 selesai!"
```