#!/bin/bash
set -e # Skrip akan berhenti otomatis jika terjadi error

echo "Mulai kompilasi dan instalasi GCC-16.2.0..."
cd /sources

# Mengekstrak kode sumber
tar -xf gcc-16.2.0.tar.xz
cd gcc-16.2.0

# Penyesuaian nama direktori pustaka 64-bit untuk arsitektur x86_64
case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
  ;;
esac

# Membuat direktori build terpisah
mkdir -v build
cd build

# Konfigurasi GCC
../configure --prefix=/usr            \
             LD=ld                    \
             --enable-languages=c,c++ \
             --enable-default-pie     \
             --enable-default-ssp     \
             --enable-host-pie        \
             --enable-targets=all     \
             --disable-multilib       \
             --disable-bootstrap      \
             --disable-fixincludes    \
             --with-system-zlib

# Kompilasi paket
make -j$(nproc)

# Menginstal paket
make install

# Memperbaiki kepemilikan direktori header yang terpasang
chown -v -R root:root $(gcc -print-file-name=include){,-fixed}

# Membuat symlink penting untuk kepatuhan FHS & LTO plugin
ln -svr /usr/bin/cpp /usr/lib
ln -sv gcc.1 /usr/share/man/man1/cc.1
ln -sfvr $(gcc -print-prog-name=liblto_plugin.so) /usr/lib/bfd-plugins/

# Pengujian Sanity Check Toolchain
echo "Menjalankan Sanity Check Toolchain..."
echo 'int main(){}' | cc -x c - -v -Wl,--verbose &> dummy.log
readelf -l a.out | grep ': /lib'
grep -E -o '/usr/lib.*/S?crt[1in].*succeeded' dummy.log
grep -B4 '^ /usr/include' dummy.log
grep 'SEARCH.*/usr/lib' dummy.log | sed 's|; |\n|g'
grep "/lib.*/libc.so.6 " dummy.log
grep found dummy.log
rm -v a.out dummy.log

# Memindahkan berkas penopang GDB ke lokasi auto-load FHS yang tepat
mkdir -pv /usr/share/gdb/auto-load/usr/lib
mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib

# Membersihkan folder ekstrak
cd /sources
rm -rf gcc-16.2.0

echo "Instalasi GCC-16.2.0 dan Sanity Check Selesai!"