#!/bin/bash

echo "Mulai proses Stripping (Pembersihan Simbol Debug)..."

# 1. Menentukan daftar pustaka kritis yang simbol debug-nya disimpan secara terpisah
save_usrlib="$(cd /usr/lib; ls ld-linux*[^g])
             libc.so.6
             libthread_db.so.1
             libquadmath.so.0.0.0
             libstdc++.so.6.0.36
             libitm.so.1.0.0
             libatomic.so.1.2.0"

cd /usr/lib

echo "[1/4] Memproses pustaka kritis & membuat file .dbg (Zstd compressed)..."
for LIB in $save_usrlib; do
    if [ -f "$LIB" ]; then
        objcopy --only-keep-debug --compress-debug-sections=zstd $LIB $LIB.dbg
        cp $LIB /tmp/$LIB
        strip --strip-unneeded /tmp/$LIB
        objcopy --add-gnu-debuglink=$LIB.dbg /tmp/$LIB
        install -vm755 /tmp/$LIB /usr/lib
        rm /tmp/$LIB
    fi
done

# 2. Menentukan biner dan pustaka aktif yang harus diproses secara aman via /tmp
online_usrbin="bash find strip"
online_usrlib="libbfd-2.47.20260726.so
               libsframe.so.3.0.0
               libhistory.so.8.3
               libncursesw.so.6.6
               libm.so.6
               libreadline.so.8.3
               libz.so.1.3.2
               libzstd.so.1.5.7
               $(cd /usr/lib; find libnss*.so* -type f 2>/dev/null)"

echo "[2/4] Memproses biner aktif via /tmp..."
for BIN in $online_usrbin; do
    if [ -f "/usr/bin/$BIN" ]; then
        cp /usr/bin/$BIN /tmp/$BIN
        strip --strip-unneeded /tmp/$BIN
        install -vm755 /tmp/$BIN /usr/bin
        rm /tmp/$BIN
    fi
done

echo "[3/4] Memproses pustaka aktif via /tmp..."
for LIB in $online_usrlib; do
    if [ -f "/usr/lib/$LIB" ]; then
        cp /usr/lib/$LIB /tmp/$LIB
        strip --strip-unneeded /tmp/$LIB
        install -vm755 /tmp/$LIB /usr/lib
        rm /tmp/$LIB
    fi
done

echo "[4/4] Menjalankan stripping massal pada sisa file biner/pustaka..."
for i in $(find /usr/lib -type f -name \*.so* ! -name \*dbg) \
         $(find /usr/lib -type f -name \*.a)                 \
         $(find /usr/{bin,sbin,libexec} -type f 2>/dev/null); do
    case "$online_usrbin $online_usrlib $save_usrlib" in
        *$(basename $i)* )
            ;;
        * )
            strip --strip-unneeded "$i" 2>/dev/null || true
            ;;
    esac
done

unset BIN LIB save_usrlib online_usrbin online_usrlib

echo "Proses Stripping Selesai! Ukuran sistem berhasil dipangkas."