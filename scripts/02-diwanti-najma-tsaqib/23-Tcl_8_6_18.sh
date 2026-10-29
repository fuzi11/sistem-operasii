#!/bin/bash
set -e # Skrip akan berhenti otomatis jika terjadi error

echo "Mulai kompilasi dan instalasi Tcl-8.6.18..."
cd /sources

# Mengekstrak kode sumber (Tcl biasanya menggunakan akhiran -src pada tarball-nya)
tar -xf tcl8.6.18-src.tar.gz
cd tcl8.6.18

# Tcl dikonfigurasi dan dikompilasi dari dalam direktori 'unix'
SRCDIR=$(pwd)
cd unix

# Konfigurasi Tcl
./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --disable-rpath

# Proses kompilasi
make -j$(nproc)

# Memodifikasi konfigurasi untuk menghapus referensi ke direktori build
sed -e "s|$SRCDIR/unix|/usr/lib|" \
    -e "s|$SRCDIR|/usr/include|"  \
    -i tclConfig.sh

sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.13|/usr/lib/tdbc1.1.13|" \
    -e "s|$SRCDIR/pkgs/tdbc1.1.13/generic|/usr/include|"     \
    -e "s|$SRCDIR/pkgs/tdbc1.1.13/library|/usr/lib/tcl8.6|"  \
    -e "s|$SRCDIR/pkgs/tdbc1.1.13|/usr/include|"             \
    -i pkgs/tdbc1.1.13/tdbcConfig.sh

sed -e "s|$SRCDIR/unix/pkgs/itcl4.3.7|/usr/lib/itcl4.3.7|" \
    -e "s|$SRCDIR/pkgs/itcl4.3.7/generic|/usr/include|"    \
    -e "s|$SRCDIR/pkgs/itcl4.3.7|/usr/include|"            \
    -i pkgs/itcl4.3.7/itclConfig.sh

unset SRCDIR

# Menguji hasil kompilasi (ditambahkan '|| true' agar jika ada kegagalan minor test tidak mematikan skrip)
echo "Menjalankan make test..."
LC_ALL=C.UTF-8 make test || true

# Menginstal paket
make install 
chmod 644 /usr/lib/libtclstub8.6.a

# Membuat library menjadi writable agar debugging symbols bisa dihapus nanti
chmod -v u+w /usr/lib/libtcl8.6.so

# Menginstal Tcl's headers yang dibutuhkan oleh paket Expect
make install-private-headers

# Membuat symbolic link yang diperlukan
ln -sfv tclsh8.6 /usr/bin/tclsh

# Mengganti nama man page agar tidak bentrok dengan man page Perl
mv -v /usr/share/man/man3/{Thread,Tcl_Thread}.3

# Menginstal dokumentasi HTML Tcl
cd ..
tar -xf ../tcl8.6.18-html.tar.gz --strip-components=1
mkdir -v -p /usr/share/doc/tcl-8.6.18
cp -v -r ./html/* /usr/share/doc/tcl-8.6.18

# Membersihkan folder ekstrak agar penyimpanan VM tidak penuh
cd /sources
rm -rf tcl8.6.18

echo "Kompilasi dan instalasi Tcl-8.6.18 Selesai!"