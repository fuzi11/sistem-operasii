#!/bin/bash
set -e # Skrip otomatis berhenti jika terjadi kesalahan

echo "=========================================="
echo " Memulai Instalasi Ninja-1.13.2 (Bab 8.20)"
echo "=========================================="

# 1. Pindah ke direktori sumber
cd /sources

# 2. Ekstraksi source tarball
tar -xf ninja-1.13.2.tar.gz
cd ninja-1.13.2

# 3. Opsional (Sangat Direkomendasikan): Patch agar Ninja mengenali variabel NINJAJOBS
# Ini mencegah Ninja menggunakan seluruh thread CPU + 2 yang bisa bikin VM crash/freeze.
sed -i '/int Guess/a \
  int   j = 0;\
  char* jobs = getenv( "NINJAJOBS" );\
  if ( jobs != NULL ) j = atoi( jobs );\
  if ( j > 0 ) return j;\
' src/ninja.cc

# 4. Kompilasi Ninja menggunakan Python 3 (--bootstrap memicu kompilasi mandiri)
python3 configure.py --bootstrap --verbose

# 5. Instalasi biner dan skrip auto-completion untuk shell (Bash & Zsh)
install -vm755 ninja /usr/bin/
install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
install -vDm644 misc/zsh-completion  /usr/share/zsh/site-functions/_ninja

# 6. Pembersihan folder sumber
cd /sources
rm -rf ninja-1.13.2

echo "=========================================="
echo " Instalasi Ninja-1.13.2 Selesai!"
echo "=========================================="