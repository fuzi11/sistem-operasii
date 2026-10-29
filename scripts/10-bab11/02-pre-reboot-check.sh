#!/bin/bash
set -e

echo "=== Memulai Pemeriksaan Pra-Reboot Sistem LFS (Section 11.3) ==="

# 1. Pembuatan /etc/vimrc jika belum ada
if [ ! -f /etc/vimrc ]; then
cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc

set nocompatible
set backspace=2
set syntax=on
set number
set hlsearch
set incsearch
set tabstop=4
set shiftwidth=4
set expandtab
set encoding=utf-8

" End /etc/vimrc
EOF
echo "[+] Berkas /etc/vimrc berhasil dibuat."
fi

# 2. Verifikasi Keberadaan Berkas Konfigurasi Utama
echo "[+] Memeriksa keberadaan berkas konfigurasi penting..."
FILES=(
    "/etc/fstab"
    "/etc/hosts"
    "/etc/inputrc"
    "/etc/profile"
    "/etc/resolv.conf"
    "/etc/vconsole.conf"
    "/etc/locale.conf"
    "/etc/os-release"
)

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  [OK] $file ditemukan."
    else
        echo "  [WARNING] $file TIDAK ditemukan!"
    fi
done

# 3. Verifikasi/Set Kata Sandi Root
echo ""
echo "[+] Memastikan kata sandi pengguna root sudah terpasang..."
passwd root

# 4. Cadangkan /etc/vimrc ke folder config/ jika direktori ada
if [ -d "/config" ]; then
    cp -v /etc/vimrc /config/vimrc
fi

echo "=== Verifikasi Pra-Reboot Selesai. Silakan ketik 'exit' atau 'logout' untuk keluar dari chroot ==="