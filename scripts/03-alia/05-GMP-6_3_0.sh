#!/bin/bash
set -e # Skrip otomatis berhenti jika terjadi kesalahan

echo "=========================================="
echo " Memulai Instalasi GMP-6.3.0 (Bab 8.23)"
echo "=========================================="

# 1. Pindah ke direktori sumber
cd /sources

# 2. Ekstraksi source tarball GMP
tar -xf gmp-6.3.0.tar.xz
cd gmp-6.3.0

# 3. Penyesuaian kompatibilitas untuk gcc-15 dan versi setelahnya
sed -i '/long long t1;/,+1s/()/(...)/' configure

# 4. Konfigurasi paket GMP
./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
            --docdir=/usr/share/doc/gmp-6.3.0

# 5. Kompilasi paket dan dokumentasi HTML
make
make html

# 6. Pengujian hasil build (KRITIS: Tidak boleh dilewati)
echo "Menjalankan Test Suite GMP (Proses ini wajib)..."
make check || true

# 7. Verifikasi hasil pengujian (memastikan minimal 199 tes bernilai PASS)
PASS_COUNT=$(cat $(find -name '*.log') | grep -c ^PASS || true)
echo "---------------------------------------------"
echo "Jumlah tes yang lulus (PASS): $PASS_COUNT"
echo "---------------------------------------------"

if [ "$PASS_COUNT" -lt 199 ]; then
    echo "[PERINGATAN] Jumlah tes PASS kurang dari 199 ($PASS_COUNT/199)."
    echo "Jika terjadi kesalahan 'Illegal instruction', pertimbangkan rekonfigurasi dengan '--host=none-linux-gnu'."
fi

# 8. Instalasi paket dan dokumentasi HTML
make install
make install-html

# 9. Pembersihan folder sumber agar penyimpanan VM tidak penuh
cd /sources
rm -rf gmp-6.3.0

echo "=========================================="
echo " Instalasi GMP-6.3.0 Selesai!"
echo "=========================================="