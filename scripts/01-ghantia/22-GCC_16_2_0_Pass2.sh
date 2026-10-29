#!/bin/bash
set -e

cd $LFS/sources
tar -xf gcc-*.tar.*
cd gcc-*

tar -xf ../mpfr-*.tar.*
mv -v mpfr-* mpfr
tar -xf ../gmp-*.tar.*
mv -v gmp-* gmp
tar -xf ../mpc-*.tar.*
mv -v mpc-* mpc

case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
  ;;
esac

mkdir -v build
cd build

../configure                   \
    --build=$(../config.guess) \
    --host=$LFS_TGT            \
    --target=$LFS_TGT          \
    --prefix=/usr              \
    --with-build-sysroot=$LFS  \
    --enable-default-pie       \
    --enable-default-ssp       \
    --disable-fixincludes      \
    --disable-nls              \
    --disable-multilib         \
    --disable-libatomic        \
    --disable-libgomp          \
    --disable-libquadmath      \
    --disable-libsanitizer     \
    --disable-libssp           \
    --disable-libvtv           \
    --enable-languages=c,c++   \
    CXX_FOR_TARGET="$LFS_TGT-gcc -nostdinc++" \
    LDFLAGS_FOR_TARGET=-L$PWD/$LFS_TGT/libgcc \
    target_configargs=gcc_cv_target_thread_file=posix

make
make DESTDIR=$LFS install

ln -sv gcc $LFS/usr/bin/cc

cd $LFS/sources
rm -rf gcc-*