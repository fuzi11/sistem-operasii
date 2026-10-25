#!/bin/bash
set -e

cd /sources
tar -xf gcc-16.2.0.tar.xz
cd gcc-16.2.0

tar -xf ../mpfr-4.2.1.tar.xz && mv -v mpfr-4.2.1 mpfr
tar -xf ../gmp-6.3.0.tar.xz && mv -v gmp-6.3.0 gmp
tar -xf ../mpc-1.3.1.tar.gz && mv -v mpc-1.3.1 mpc

case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' -i.bak gcc/config/i386/t-linux64
  ;;
esac

sed -e '/thread_header=/s:=.*:=${posix_thread_header}:' \
    -i libgcc/configure

mkdir -v build
cd build

time {
  ../configure \
    --build=$(../gcc/config.guess) \
    --host=$LFS_TGT \
    --target=$LFS_TGT \
    LDFLAGS_FOR_TARGET="-L$LFS/tools/lib" \
    --prefix=$LFS/tools \
    --with-glibc-version=2.40 \
    --with-sysroot=$LFS \
    --enable-languages=c,c++ \
    --enable-default-pie \
    --enable-default-ssp \
    --disable-nls \
    --disable-multilib \
    --disable-libgomp \
    --disable-libquadmath \
    --disable-feature-tests \
    --disable-server \
    --disable-target-zlib \
    --enable-pointer-size-check \
    && make \
    && make install \
    && ln -sfv gcc $LFS/tools/bin/cc
}

cd /sources
rm -rf gcc-16.2.0
