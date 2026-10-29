#!/bin/bash
set -e

echo "Mengonfigurasi System Locale dan /etc/profile (Section 9.7)..."

# 1. Membuat berkas /etc/locale.conf dengan default en_US.UTF-8
cat > /etc/locale.conf << "EOF"
LANG=en_US.UTF-8
EOF
echo "[+] Berkas /etc/locale.conf berhasil dibuat (LANG=en_US.UTF-8)."

# 2. Membuat berkas /etc/profile untuk mengelola variabel lingkungan shell
cat > /etc/profile << "EOF"
# Begin /etc/profile

for i in $(locale); do
  unset ${i%=*}
done

if [[ "$TERM" = linux ]]; then
  export LANG=C.UTF-8
else
  source /etc/locale.conf

  for i in $(locale); do
    key=${i%=*}
    if [[ -v $key ]]; then
      export $key
    fi
  done
fi

# End /etc/profile
EOF
echo "[+] Berkas /etc/profile berhasil dibuat."

echo "Konfigurasi System Locale Selesai!"