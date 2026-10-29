#!/bin/bash
set -e # Skrip otomatis berhenti jika terjadi kesalahan

echo "=========================================="
echo " Memulai Instalasi DejaGNU-1.6.3 (Bab 8.19)"
echo "=========================================="

# 1. Pindah ke direktori sumber
cd /sources

# 2. Ekstraksi source tarball
tar -xf dejagnu-1.6.3.tar.gz
cd dejagnu-1.6.3

# 3. Buat direktori build terpisah sesuai saran upstream
mkdir -v build
cd build

# 4. Konfigurasi paket
../configure --prefix=/usr

# 5. Generasi dokumentasi (HTML dan Plaintext)
makeinfo --html --no-split -o doc/dejagnu.html ../doc/dejagnu.texi
makeinfo --plaintext       -o doc/dejagnu.txt  ../doc/dejagnu.texi

# 7. Instalasi paket dan dokumentasi
make install
install -v -dm755  /usr/share/doc/dejagnu-1.6.3
install -v -m644   doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.3

# 8. Pembersihan folder sumber agar ruang penyimpanan tidak penuh
cd /sources
rm -rf dejagnu-1.6.3

echo "=========================================="
echo " Instalasi DejaGNU-1.6.3 Selesai!"
echo "=========================================="