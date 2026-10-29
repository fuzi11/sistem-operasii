
#!/bin/bash
set -e

cd $LFS/sources
tar -xf gcc-16.2.0.tar.xz
cd gcc-16.2.0

mkdir -v build
cd build

../libstdc++-v3/configure \
    --host="$LFS_TGT" \
    --build="$(../config.guess)" \
    CXX="$LFS_TGT-gcc" \
    --prefix=/usr \
    --disable-multilib \
    --disable-nls \
    --disable-libstdcxx-pch \
    --with-gxx-include-dir="/tools/$LFS_TGT/include/c++/16.2.0"

make
make DESTDIR="$LFS" install

rm -v "$LFS"/usr/lib/lib{stdc++{,exp,fs},supc++}.la
