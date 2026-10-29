#!/bin/bash
set -e # Skrip akan berhenti otomatis jika terjadi error

echo "Mulai kompilasi dan instalasi Bzip2-1.0.8..."
cd /sources

# Mengekstrak kode sumber (umumnya bzip2 menggunakan .tar.gz)
tar -xf bzip2-1.0.8.tar.gz
cd bzip2-1.0.8

# Menerapkan patch untuk instalasi dokumentasi
patch -Np1 -i ../bzip2-1.0.8-install_docs-1.patch

# Memastikan symbolic link terinstal secara relatif
sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile

# Memastikan man pages diinstal ke lokasi yang benar
sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile

# Persiapan kompilasi menggunakan Makefile khusus untuk shared library
make -f Makefile-libbz2_so
make clean

# Proses kompilasi dan pengujian (make otomatis melakukan test pada Bzip2)
make -j$(nproc)

# Menginstal program binary
make PREFIX=/usr install

# Menginstal shared library dan symlink kompatibilitas
cp -av libbz2.so.* /usr/lib
ln -sfv libbz2.so.1.0.8 /usr/lib/libbz2.so
ln -sfv libbz2.so.1.0.8 /usr/lib/libbz2.so.1

# Menginstal binary bzip2 shared ke /usr/bin dan menimpa dengan symlink
cp -v bzip2-shared /usr/bin/bzip2
for i in /usr/bin/{bzcat,bunzip2}; do
  ln -sfv bzip2 $i
done

# Menghapus static library yang tidak digunakan
rm -fv /usr/lib/libbz2.a

# Membersihkan folder ekstrak agar penyimpanan VM tidak penuh
cd ..
rm -rf bzip2-1.0.8

echo "Kompilasi dan instalasi Bzip2-1.0.8 Selesai!"