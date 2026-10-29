#!/bin/bash
set -e # Skrip akan berhenti otomatis jika terjadi error

echo "Mulai instalasi Man-pages-6.18..."
cd /sources

# Mengekstrak kode sumber
tar -xf man-pages-6.18.tar.xz
cd man-pages-6.18

# Menghapus dua man pages untuk fungsi password hashing sesuai panduan
rm -v man3/crypt*

# Menginstal paket langsung (tanpa configure/make sebelumnya)
make -R GIT=false prefix=/usr install

# Membersihkan folder ekstrak agar penyimpanan VM tidak penuh
cd ..
rm -rf man-pages-6.18

echo "Instalasi Man-pages-6.18 Selesai!"