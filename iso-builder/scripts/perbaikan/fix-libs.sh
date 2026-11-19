#!/bin/bash
L=/mnt/lfs
Q=/root/musl-quarantine
CH="chroot $L /usr/bin/env -i PATH=/usr/sbin:/usr/bin /usr/bin/bash -c"
mountpoint -q $L || { echo "STOP: sda2 belum ter-mount"; exit 1; }

echo "== 1. hapus symlink rusak sisa Alpine =="
find $L/usr/lib -maxdepth 1 -xtype l -print -delete | sed "s|^$L||"

echo; echo "== 2. libstdc++ =="
ls -l $L/usr/lib/libstdc++.so* 2>&1 | sed "s|$L||"
REALSTD=$(ls $L/usr/lib/libstdc++.so.6.0.* 2>/dev/null | grep -E 'so\.6\.0\.[0-9]+$' | sort -V | tail -1)
if [ -n "$REALSTD" ]; then ln -sfn "$(basename "$REALSTD")" $L/usr/lib/libstdc++.so.6; echo "[ok] libstdc++.so.6 -> $(basename "$REALSTD")"
else echo "[WARN] libstdc++ asli (tanpa .dbg) tidak ada"; fi

echo; echo "== 3. libgcc_s.so.1 (sementara, dari host) =="
if [ -e $L/usr/lib/libgcc_s.so.1 ]; then echo "sudah ada, dilewati"
else
  H=/lib/x86_64-linux-gnu/libgcc_s.so.1
  NEED=$(readelf -V $L/usr/lib/libstdc++.so.6 2>/dev/null | grep -o 'GCC_[0-9.]*' | sort -uV | tail -1)
  HAVE=$(readelf -V $H | grep -o 'GCC_[0-9.]*' | sort -uV | tail -1)
  echo "libstdc++ LFS butuh sampai: ${NEED:-?}   host menyediakan sampai: $HAVE"
  if [ -z "$NEED" ] || [ "$(printf '%s\n%s\n' "$NEED" "$HAVE" | sort -V | tail -1)" = "$HAVE" ]; then
    install -m 755 $H $L/usr/lib/libgcc_s.so.1 && echo "[ok] libgcc_s.so.1 dipasang dari host"
  else echo "[WARN] libgcc_s host terlalu lama, TIDAK dipasang"; fi
fi

echo; echo "== 4. file OpenSSL yang ada =="
find $L -xdev \( -name 'libcrypto*' -o -name 'libssl*' \) 2>/dev/null | sed "s|^$L||"
echo "-- tercatat di karantina:"
grep -iE 'libcrypto|libssl|ossl' $Q/files.txt | head -20

echo; echo "== 5. ldconfig + uji =="
$CH 'ldconfig' && echo ldconfig-ok
$CH 'gcc -dumpfullversion; echo "int main(void){return 0;}" > /tmp/t.c && gcc /tmp/t.c -o /tmp/t && /tmp/t && echo GCC-OK; rm -f /tmp/t /tmp/t.c'
for b in /usr/sbin/sshd /usr/sbin/nginx /usr/bin/login /usr/bin/su /usr/bin/bash /usr/bin/fastfetch /usr/bin/systemctl; do
  printf '%s: ' $b; $CH "ldd $b 2>&1 | grep -E 'not found|musl' | tr -s ' \n' ' '"; echo
done
echo "== selesai =="
