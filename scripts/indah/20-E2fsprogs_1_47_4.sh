#!/bin/bash
set -e # Skrip akan berhenti otomatis jika terjadi error

echo "Mulai kompilasi dan instalasi E2fsprogs-1.47.4..."
cd /sources

# Mengekstrak kode sumber
tar -xf e2fsprogs-1.47.4.tar.gz
cd e2fsprogs-1.47.4

# Membuat direktori build terpisah sesuai rekomendasi upstream
mkdir -v build
cd build

# Konfigurasi E2fsprogs
../configure --prefix=/usr       \
             --sysconfdir=/etc   \
             --enable-elf-shlibs \
             --disable-libblkid  \
             --disable-libuuid   \
             --disable-uuidd     \
             --disable-fsck

# Proses kompilasi
make -j$(nproc)

# Menginstal paket
make install

# Menghapus pustaka statis yang tidak diperlukan
rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a

# Memperbarui dan mengintegrasikan halaman info ke dalam direktori sistem
gunzip -v /usr/share/info/libext2fs.info.gz
install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info

makeinfo -o doc/com_err.info ../lib/et/com_err.texinfo
install -v -m644 doc/com_err.info /usr/share/info
install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info

# Membersihkan folder ekstrak
cd /sources
rm -rf e2fsprogs-1.47.4

echo "Instalasi dan Konfigurasi E2fsprogs-1.47.4 Selesai!"