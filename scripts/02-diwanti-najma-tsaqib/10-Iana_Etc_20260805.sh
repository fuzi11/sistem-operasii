#!/bin/bash
set -e # Skrip akan berhenti otomatis jika terjadi error

echo "Mulai instalasi Iana-Etc-20260805..."
cd /sources

# Mengekstrak kode sumber (sesuaikan ekstensi jika menggunakan .tar.xz)
tar -xf iana-etc-20260805.tar.gz
cd iana-etc-20260805

# Mengkopi file services dan protocols langsung ke /etc sesuai panduan LFS
cp -v services protocols /etc

# Membersihkan folder ekstrak agar penyimpanan VM tidak penuh
cd ..
rm -rf iana-etc-20260805

echo "Instalasi Iana-Etc-20260805 Selesai!"