#!/bin/bash
set -e # Skrip akan berhenti otomatis jika terjadi error

echo "Mulai kompilasi dan instalasi Expect-5.45.4..."

# Memeriksa PTY sebelum memulai kompilasi (Wajib sesuai panduan LFS)
echo "Memeriksa konfigurasi PTY..."
python3 -c 'from pty import spawn; spawn(["echo", "ok"])' || {
    echo "ERROR: PTY tidak berfungsi (out of pty devices)!"
    echo "Harap keluar dari chroot dan mount kembali devpts sesuai panduan LFS Bab 7.3."
    exit 1
}

cd /sources

# Mengekstrak kode sumber (nama direktori/tarball expect tidak menggunakan tanda hubung sebelum versi)
tar -xf expect5.45.4.tar.gz
cd expect5.45.4

# Mengaplikasikan patch gcc-15.1
patch -Np1 -i ../expect-5.45.4-gcc15-1.patch

# Konfigurasi Expect
./configure --prefix=/usr           \
            --with-tcl=/usr/lib     \
            --enable-shared         \
            --disable-rpath         \
            --mandir=/usr/share/man \
            --with-tclinclude=/usr/include

# Proses kompilasi
make

# Menguji hasil kompilasi
echo "Menjalankan make test..."
make test

# Menginstal paket
make install

# Membuat symbolic link
ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib

# Membersihkan folder ekstrak agar penyimpanan VM tidak penuh
cd ..
rm -rf expect5.45.4

echo "Kompilasi dan instalasi Expect-5.45.4 Selesai!"