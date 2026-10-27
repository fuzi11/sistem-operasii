#!/bin/bash
set -e # Skrip otomatis berhenti jika terjadi kesalahan

echo "=========================================="
echo " Memulai Instalasi GCC-16.2.0 (Bab 8.32)"
echo "=========================================="

# 1. Pindah ke direktori sumber
cd /sources

# 2. Ekstraksi source tarball GCC
tar -xf gcc-16.2.0.tar.xz
cd gcc-16.2.0

# 3. Ubah nama direktori default pustaka 64-bit menjadi "lib" (khusus x86_64)
case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
  ;;
esac

# 4. Buat direktori build terpisah sesuai rekomendasi panduan LFS
mkdir -v build
cd build

# 5. Konfigurasi paket GCC
../configure --prefix=/usr            \
             LD=ld                    \
             --enable-languages=c,c++ \
             --enable-default-pie     \
             --enable-default-ssp     \
             --enable-host-pie        \
             --enable-targets=all     \
             --disable-multilib       \
             --disable-bootstrap      \
             --disable-fixincludes    \
             --with-system-zlib

# 6. Kompilasi paket
make -j4

# 7. Pengujian hasil build (Sangat Direkomendasikan / Wajib)
# Mengatur batas stack ke unlimited sebelum menjalankan testing
ulimit -s -H unlimited

echo "Menjalankan Test Suite GCC sebagai user tester..."
chown -R tester .
# Menjalankan make check secara paralel (-j4) dan '|| true' agar kegagalan test yang diketahui tidak menghentikan skrip
su tester -c "PATH=$PATH make -j4 -k check" || true

echo "--- Ringkasan Ringkas Test Suite GCC ---"
../contrib/test_summary -t | grep -A7 Summ || echo "Tidak dapat mengekstrak ringkasan test_summary."
echo "---------------------------------------"

# 8. Instalasi paket
make install

# 9. Mengembalikan kepemilikan direktori header ke user root
chown -v -R root:root $(gcc -print-file-name=include){,-fixed}

# 10. Membuat symlink kompatibilitas FHS & LTO Plugin
ln -svr /usr/bin/cpp /usr/lib
ln -sv gcc.1 /usr/share/man/man1/cc.1
ln -sfvr $(gcc -print-prog-name=liblto_plugin.so) /usr/lib/bfd-plugins/

# 11. Sanity Check (Uji Kelayakan Kompiler & Linker Baru)
echo "Menjalankan Sanity Check pada GCC..."
echo 'int main(){}' | cc -x c - -v -Wl,--verbose &> dummy.log

# Verifikasi 1: Program Interpreter / Dynamic Linker
echo "[Sanity Check 1] Dynamic Linker:"
readelf -l a.out | grep ': /lib'

# Verifikasi 2: Dynamic Start Files (crt1.o, crti.o, crtn.o)
echo "[Sanity Check 2] Start Files:"
grep -E -o '/usr/lib.*/S?crt[1in].*succeeded' dummy.log

# Verifikasi 3: Header Search Paths
echo "[Sanity Check 3] Header Search Paths:"
grep -B4 '^ /usr/include' dummy.log

# Verifikasi 4: Linker Search Paths
echo "[Sanity Check 4] Linker Search Paths:"
grep 'SEARCH.*/usr/lib' dummy.log | sed 's|; |\n|g'

# Verifikasi 5: Penggunaan libc
echo "[Sanity Check 5] libc.so.6:"
grep "/lib.*/libc.so.6 " dummy.log

# Verifikasi 6: Penetapan Dynamic Linker
echo "[Sanity Check 6] Linker Found:"
grep found dummy.log

# Membersihkan file pengujian sanity check
rm -v a.out dummy.log

# 12. Pindahkan file auto-load GDB ke lokasi yang sesuai
mkdir -pv /usr/share/gdb/auto-load/usr/lib
mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib || true

# 13. Pembersihan folder sumber agar penyimpanan VM tidak penuh
cd /sources
rm -rf gcc-16.2.0

echo "=========================================="
echo " Instalasi & Verifikasi GCC-16.2.0 Selesai!"
echo "=========================================="