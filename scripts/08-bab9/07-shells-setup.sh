#!/bin/bash
set -e

echo "Mengonfigurasi Berkas /etc/shells (Section 9.9)..."

cat > /etc/shells << "EOF"
# Begin /etc/shells

/bin/sh
/bin/bash

# End /etc/shells
EOF

echo "[+] Berkas /etc/shells berhasil dibuat."