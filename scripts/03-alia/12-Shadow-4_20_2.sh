#!/bin/bash
set -e # Skrip otomatis berhenti jika terjadi kesalahan

echo "=========================================="
echo " Memulai Instalasi Shadow-4.20.2 (Bab 8.30)"
echo "=========================================="

# 1. Pindah ke direktori sumber
cd /sources

# 2. Ekstraksi source tarball Shadow
tar -xf shadow-4.20.2.tar.xz
cd shadow-4.20.2

# 3. Cegah instalasi halaman manual yang sudah dipasang di Bab 8.3 (Man-pages)
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;

# 4. Ubah metode enkripsi ke YESCRYPT, ubah lokasi spool mail ke /var/mail,
#    serta hapus /bin dan /sbin dari PATH bawaan di etc/login.defs
sed -e 's:#ENCRYPT_METHOD SHA512:ENCRYPT_METHOD YESCRYPT:' \
    -e 's:/var/spool/mail:/var/mail:'                      \
    -e '/PATH=/{s@/sbin:@@;s@/bin:@@}'                     \
    -i etc/login.defs

# 5. Buat file dummy /usr/bin/passwd jika belum ada agar instalasi tidak meletakkannya di tempat salah
touch /usr/bin/passwd

# 6. Konfigurasi paket Shadow
./configure --sysconfdir=/etc   \
            --disable-static    \
            --with-{b,yes}crypt \
            --without-libbsd    \
            --disable-logind    \
            --with-group-name-max-length=32

# 7. Kompilasi paket (tidak memiliki test suite)
make

# 8. Instalasi paket dan man-pages
make exec_prefix=/usr install
make -C man install-man

# 9. Konfigurasi Sistem Shadow (pwconv & grpconv)
pwconv
grpconv

# 10. Konfigurasi default untuk utility useradd
mkdir -p /etc/default
useradd -D --gid 999

# 11. Buat file kosongan /etc/subuid dan /etc/subgid
touch /etc/sub{u,g}id

# 12. Mengatur Kata Sandi Root (Default: "root", silakan ubah di kemudian hari)
# Menggunakan chpasswd agar skrip otomatisasi tidak berhenti menunggu masukan interaktif terminal.
echo "root:root" | chpasswd
echo "[CATATAN] Password root sementara telah diatur ke: root"

# 13. Pembersihan folder sumber agar penyimpanan VM tidak penuh
cd /sources
rm -rf shadow-4.20.2

echo "=========================================="
echo " Instalasi Shadow-4.20.2 Selesai!"
echo "=========================================="