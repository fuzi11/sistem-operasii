#!/bin/bash
set -e # Skrip akan berhenti otomatis jika terjadi error

echo "Mulai kompilasi dan instalasi Systemd-261.2..."
cd /sources

# Mengekstrak kode sumber
tar -xf systemd-261.2.tar.gz
cd systemd-261.2

# Menghapus dua grup yang tidak diperlukan dari aturan udev default
sed -e 's/GROUP="render"/GROUP="video"/' \
    -e 's/GROUP="sgx", //'               \
    -i rules.d/50-udev-default.rules.in

# Membuat direktori build terpisah
mkdir -pv build
cd build

# Konfigurasi Systemd dengan Meson
meson setup ..                \
      --prefix=/usr           \
      --buildtype=release     \
      -D default-dnssec=no    \
      -D firstboot=false      \
      -D install-tests=false  \
      -D ldconfig=false       \
      -D sysusers=false       \
      -D rpmmacrosdir=no      \
      -D homed=disabled       \
      -D man=disabled         \
      -D mode=release         \
      -D pamconfdir=no        \
      -D dev-kvm-mode=0660    \
      -D nobody-group=nogroup \
      -D sysupdate=disabled   \
      -D ukify=disabled       \
      -D docdir=/usr/share/doc/systemd-261.2

# Proses kompilasi
ninja

# Menginstal paket
ninja install

# Menginstal man-pages yang sudah siap dari tarball terpisah
tar -xf ../../systemd-man-pages-261.2.tar.xz \
    --no-same-owner --strip-components=1     \
    -C /usr/share/man

# Membuat berkas /etc/machine-id yang dibutuhkan oleh systemd-journald
systemd-machine-id-setup

# Mengatur struktur target dasar systemd
systemctl preset-all

# Membersihkan folder ekstrak
cd /sources
rm -rf systemd-261.2

echo "Instalasi dan Konfigurasi Systemd-261.2 Selesai!"