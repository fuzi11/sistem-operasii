#!/bin/bash
set -e # Skrip akan berhenti otomatis jika terjadi error

echo "Mulai kompilasi dan instalasi Vim-9.2.1025..."
cd /sources

# Mengekstrak kode sumber
tar -xf vim-9.2.1025.tar.gz
cd vim-9.2.1025

# Mengubah lokasi default berkas konfigurasi vimrc ke /etc
echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h

# Konfigurasi Vim
./configure --prefix=/usr

# Proses kompilasi
make -j$(nproc)

# Menginstal paket
make install

# Membuat symlink untuk vi dan man-pages dalam berbagai bahasa
ln -sv vim /usr/bin/vi
for L in /usr/share/man/{,*/}man1/vim.1; do
    ln -sv vim.1 $(dirname $L)/vi.1
done

# Membuat symlink dokumentasi agar konsisten dengan struktur direktori LFS
ln -sv ../vim/vim92/doc /usr/share/doc/vim-9.2.1025

# Membuat berkas konfigurasi sistem /etc/vimrc
cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc

" Ensure defaults are set before customizing settings, not after
source $VIMRUNTIME/defaults.vim
let skip_defaults_vim=1

set nocompatible
set backspace=2
set mouse=
syntax on
if (&term == "xterm") || (&term == "putty")
  set background=dark
endif

" End /etc/vimrc
EOF

# Membersihkan folder ekstrak
cd /sources
rm -rf vim-9.2.1025

echo "Instalasi dan Konfigurasi Vim-9.2.1025 Selesai!"