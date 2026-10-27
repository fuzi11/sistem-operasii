#!/bin/bash
set -e # Skrip otomatis berhenti jika terjadi kesalahan

echo "=========================================="
echo " Memulai Instalasi Bash-5.3 (Bab 8.39)"
echo "=========================================="

# 1. Pindah ke direktori sumber
cd /sources

# 2. Ekstraksi source tarball Bash
tar -xf bash-5.3.tar.gz
cd bash-5.3

# 3. Konfigurasi paket Bash
./configure --prefix=/usr             \
            --without-bash-malloc     \
            --with-installed-readline \
            --docdir=/usr/share/doc/bash-5.3

# 4. Kompilasi paket
make

# 5. Pengujian hasil build (Memerlukan pty via Expect dan dijalankan sebagai user tester)
echo "Menjalankan Test Suite Bash..."
chown -R tester .
LC_ALL=C.UTF-8 su -s /usr/bin/expect tester << "EOF" || true
set timeout -1
spawn make tests
expect eof
lassign [wait] _ _ _ value
exit $value
EOF

# 6. Instalasi paket
make install

# 7. Pembersihan folder sumber sebelum mengganti shell aktif
cd /sources
rm -rf bash-5.3

echo "=========================================="
echo " Instalasi Bash-5.3 Selesai!"
echo "=========================================="

# 8. Menjalankan program bash yang baru dibuat (Menggantikan shell yang sedang berjalan)
exec /usr/bin/bash --login