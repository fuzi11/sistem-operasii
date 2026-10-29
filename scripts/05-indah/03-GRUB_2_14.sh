#!/bin/bash
set -e # Skrip akan berhenti otomatis jika terjadi error

echo "Mulai kompilasi dan instalasi GRUB-2.14..."
cd /sources

# Menghapus variabel flags kompilasi sesuai peringatan LFS
unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS

# Mengekstrak kode sumber
tar -xf grub-2.14.tar.xz
cd grub-2.14

# Memperbaiki bug pada berkas configure
sed 's/--image-base/--nonexist-linker-option/' -i configure

# =========================================================
# 1. Kompilasi & Instalasi GRUB untuk BIOS
# =========================================================
echo "Membangun GRUB untuk arsitektur BIOS..."
./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --disable-efiemu  \
            --disable-werror

make -j$(nproc)
make install

# =========================================================
# 2. Kompilasi & Instalasi GRUB untuk 64-bit UEFI
# =========================================================
echo "Membuka pembersihan direktori untuk kompilasi UEFI..."
make clean

echo "Membangun GRUB untuk arsitektur 64-bit UEFI..."
./configure --prefix=/usr       \
            --sysconfdir=/etc   \
            --target=x86_64     \
            --with-platform=efi \
            --disable-efiemu    \
            --disable-werror

make -j$(nproc)
make install

# Membersihkan folder ekstrak
cd /sources
rm -rf grub-2.14

echo "Instalasi GRUB-2.14 (BIOS & 64-bit UEFI) Selesai!"