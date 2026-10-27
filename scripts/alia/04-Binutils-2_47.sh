#!/bin/bash
set -e # Skrip otomatis berhenti jika terjadi kesalahan

echo "=========================================="
echo " Memulai Instalasi Binutils-2.47 (Bab 8.22)"
echo "=========================================="

# 1. Pindah ke direktori sumber
cd /sources

# 2. Ekstraksi source tarball Binutils
tar -xf binutils-2.47.tar.xz
cd binutils-2.47

# 3. Buat direktori build terpisah sesuai rekomendasi panduan LFS
mkdir -v build
cd build

# 4. Konfigurasi paket Binutils
../configure --prefix=/usr       \
             --sysconfdir=/etc   \
             --enable-ld=default \
             --enable-plugins    \
             --enable-shared     \
             --disable-werror    \
             --enable-64-bit-bfd \
             --enable-new-dtags  \
             --with-system-zlib  \
             --with-lib-path=/usr/lib \
             --enable-default-hash-style=gnu

# 5. Kompilasi paket
make tooldir=/usr

# 6. Pengujian hasil build (KRITIS: Tidak boleh dilewati)
# Menggunakan 'make -k check' agar pengujian terus berjalan meskipun ada error individual.
# Menggunakan '|| true' agar skrip bash tidak terhenti karena baris 'make -k' mengembalikan exit status non-zero jika ada test yang fail.
echo "Menjalankan Test Suite Binutils (Proses ini wajib)..."
make -k check || true

# Menampilkan daftar pengujian yang gagal ke layar (1 kegagalan terkait gprofng adalah normal/diketahui)
echo "--- Ringkasan Kegagalan Test Suite (FAIL) ---"
grep '^FAIL:' $(find -name '*.log') || echo "Tidak ada FAIL lain yang ditemukan."
echo "---------------------------------------------"

# 7. Instalasi paket
make tooldir=/usr install

# 8. Hapus pustaka statis dan dokumentasi gprofng yang tidak berguna
rm -rfv /usr/lib/lib{bfd,ctf,ctf-nobfd,gprofng,opcodes,sframe}.a \
        /usr/share/doc/gprofng/

# 9. Pembersihan folder sumber agar ruang penyimpanan VM tidak penuh
cd /sources
rm -rf binutils-2.47

echo "=========================================="
echo " Instalasi Binutils-2.47 Selesai!"
echo "=========================================="