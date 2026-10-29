#!/bin/bash
set -e # Skrip akan berhenti otomatis jika terjadi error

echo "Mulai kompilasi Perl-5.44.0..."
cd /sources

# Mengekstrak kode sumber (sesuaikan ekstensi tarball jika menggunakan .tar.gz)
tar -xf perl-5.44.0.tar.xz
cd perl-5.44.0

# Konfigurasi Perl
# Menggunakan parameter -des untuk otomatisasi (defaults, ensure completion, silence non-essential)
sh Configure -des                                         \
             -D prefix=/usr                               \
             -D vendorprefix=/usr                         \
             -D useshrplib                                \
             -D privlib=/usr/lib/perl5/5.44/core_perl     \
             -D archlib=/usr/lib/perl5/5.44/core_perl     \
             -D sitelib=/usr/lib/perl5/5.44/site_perl     \
             -D sitearch=/usr/lib/perl5/5.44/site_perl    \
             -D vendorlib=/usr/lib/perl5/5.44/vendor_perl \
             -D vendorarch=/usr/lib/perl5/5.44/vendor_perl

# Proses kompilasi 
make -j$(nproc)

# Menginstal paket
make install

# Membersihkan folder ekstrak agar penyimpanan VM tidak penuh
cd ..
rm -rf perl-5.44.0

echo "Kompilasi dan instalasi Perl-5.44.0 Selesai!"