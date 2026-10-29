#!/bin/bash
set -e # Skrip otomatis berhenti jika terjadi kesalahan

echo "=========================================="
echo " Memulai Instalasi Pkgconf-3.0.5 (Bab 8.21)"
echo "=========================================="

# 1. Pindah ke direktori sumber
cd /sources

# 2. Ekstraksi source tarball Pkgconf
tar -xf pkgconf-3.0.5.tar.xz
cd pkgconf-3.0.5

# 3. Solusi dependensi sirkular: Ekstraksi tarball Meson di dalam direktori Pkgconf
tar -xf ../meson-1.12.0.tar.gz

# 4. Buat direktori build terpisah
mkdir build
cd build

# 5. Konfigurasi menggunakan skrip Python Meson secara langsung
python3 ../meson-1.12.0/meson.py setup --prefix=/usr --buildtype=release ..

# 6. Kompilasi paket menggunakan Ninja
ninja


# 8. Instalasi paket
ninja install

# 9. Penyesuaian nama folder dokumentasi versi
mv -v /usr/share/doc/pkgconf{,-3.0.5}

# 10. Membuat symlink untuk menjaga kompatibilitas dengan Pkg-config standar
ln -sv pkgconf   /usr/bin/pkg-config
ln -sv pkgconf.1 /usr/share/man/man1/pkg-config.1

# 11. Pembersihan folder sumber agar penyimpanan VM tidak penuh
cd /sources
rm -rf pkgconf-3.0.5

echo "=========================================="
echo " Instalasi Pkgconf-3.0.5 Selesai!"
echo "=========================================="