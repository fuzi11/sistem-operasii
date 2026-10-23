```bash
#!/bin/bash
set -e

echo "Mulai instalasi Expat-2.8.3..."

# Masuk ke direktori sumber LFS
cd /sources

# Mengekstrak source code Expat
tar -xf expat-2.8.3.tar.xz
cd expat-2.8.3

# Konfigurasi Expat sesuai panduan LFS
./configure --prefix=/usr \
            --disable-static \
            --docdir=/usr/share/doc/expat-2.8.3

# Mengompilasi Expat
make

# Menguji hasil kompilasi
make check

# Menginstal Expat
make install

# Menginstal dokumentasi (opsional)
install -v -m644 doc/*.{html,css} /usr/share/doc/expat-2.8.3

# Kembali dan membersihkan source code
cd /sources
rm -rf expat-2.8.3

echo "Instalasi Expat-2.8.3 selesai!"
```