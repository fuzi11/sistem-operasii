```bash
#!/bin/bash
set -e

echo "Mulai instalasi GDBM-1.26..."

# Masuk ke direktori sumber LFS
cd /sources

# Mengekstrak source code GDBM
tar -xf gdbm-1.26.tar.gz
cd gdbm-1.26

# Konfigurasi GDBM sesuai panduan LFS
./configure --prefix=/usr \
            --disable-static \
            --enable-libgdbm-compat

# Mengompilasi GDBM
make

# Menguji hasil kompilasi
make check

# Menginstal GDBM
make install

# Kembali dan membersihkan source code
cd /sources
rm -rf gdbm-1.26

echo "Instalasi GDBM-1.26 selesai!"
```