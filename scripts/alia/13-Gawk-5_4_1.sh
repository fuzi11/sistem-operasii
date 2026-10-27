#!/bin/bash
set -e # Skrip otomatis berhenti jika terjadi kesalahan

echo "=========================================="
echo " Memulai Instalasi Gawk-5.4.1 (Bab 8.31)"
echo "=========================================="

# 1. Pindah ke direktori sumber
cd /sources

# 2. Ekstraksi source tarball Gawk
tar -xf gawk-5.4.1.tar.xz
cd gawk-5.4.1

# 3. Mencegah instalasi file tambahan yang tidak diperlukan
sed -i 's/extras//' Makefile.in

# 4. Konfigurasi paket Gawk
./configure --prefix=/usr

# 5. Kompilasi paket
make

# 6. Pengujian hasil build (Dijalankan menggunakan user tester)
echo "Menjalankan Test Suite Gawk..."
chown -R tester .
su tester -c "PATH=$PATH make check" || true

# 7. Hapus biner gawk-5.4.1 lama agar hard link diperbarui dengan benar saat make install
rm -f /usr/bin/gawk-5.4.1

# 8. Instalasi paket
make install

# 9. Buat symlink man page untuk awk yang mengarah ke gawk.1
ln -sv gawk.1 /usr/share/man/man1/awk.1

# 10. (Opsional) Instalasi dokumentasi tambahan
install -vDm644 doc/{awkforai.txt,*.{eps,pdf,jpg}} -t /usr/share/doc/gawk-5.4.1

# 11. Pembersihan folder sumber agar penyimpanan VM tidak penuh
cd /sources
rm -rf gawk-5.4.1

echo "=========================================="
echo " Instalasi Gawk-5.4.1 Selesai!"
echo "=========================================="