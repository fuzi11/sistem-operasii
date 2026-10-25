
#!/bin/bash
set -e

cd /sources
tar -xf binutils-2.47.tar.xz
cd binutils-2.47

mkdir -v build
cd build

time {
  ../configure \
    --prefix=$LFS/tools \
    --with-sysroot=$LFS \
    --target=$LFS_TGT \
    --disable-nls \
    --enable-gprofng=no \
    --disable-werror \
    --enable-new-dtags \
    --enable-default-hash-style=gnu \
    && make \
    && make install
}

cd /sources
rm -rf binutils-2.47
