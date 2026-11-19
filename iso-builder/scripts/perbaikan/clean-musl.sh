#!/bin/bash
L=/mnt/lfs
DB=$L/lib/apk/db/installed
Q=/root/musl-quarantine
CH="chroot $L /usr/bin/env -i PATH=/usr/sbin:/usr/bin /usr/bin/bash -c"
mountpoint -q $L || { echo "STOP: sda2 belum ter-mount"; exit 1; }
[ -f $DB ] || { echo "STOP: db apk tidak ada"; exit 1; }
file -L $L/usr/bin/bash | grep -q 'ld-linux-x86-64' || { echo "STOP: bash glibc tidak ditemukan"; exit 1; }
mkdir -p $Q

# 1. daftar file musl milik apk + symlink busybox
: > $Q/files.txt
awk -F: '/^F:/{d=$2} /^R:/{print d"/"$2}' $DB | sed 's|^/||' | while read -r p; do
  f="$L/$p"; [ -f "$f" ] && [ ! -L "$f" ] || continue
  if readelf -d "$f" 2>/dev/null | grep -q 'libc.musl' || file -b "$f" | grep -q 'ld-musl'; then echo "$p"; fi
done >> $Q/files.txt
( cd $L && find usr/bin usr/sbin -lname '*busybox*' ) >> $Q/files.txt
sort -u $Q/files.txt -o $Q/files.txt
tar czf $Q/musl-files.tgz -C $L -T $Q/files.txt 2>/dev/null
echo "[backup] $(wc -l < $Q/files.txt) entri -> $Q/musl-files.tgz ($(du -h $Q/musl-files.tgz | cut -f1))"

# 2. hapus
while read -r p; do rm -f "$L/$p"; done < $Q/files.txt
rm -f $L/lib/ld-musl-x86_64.so.1 $L/usr/lib/ld-musl-x86_64.so.1

# 3. pulihkan /bin/sh -> bash
ln -sfn bash $L/usr/bin/sh
[ -L $L/bin ] || ln -sfn bash $L/bin/sh
echo "[ok] sh -> $(readlink $L/usr/bin/sh)"

# 4. perbaiki symlink library
for x in ncursesw formw menuw panelw; do
  [ -e $L/usr/lib/lib$x.so.6.6 ] && ln -sfn lib$x.so.6.6 $L/usr/lib/lib$x.so.6
done
REALSTD=$(ls $L/usr/lib/libstdc++.so.6.0.* 2>/dev/null | grep -v '6\.0\.30$' | sort -V | tail -1)
if [ -n "$REALSTD" ]; then ln -sfn "$(basename $REALSTD)" $L/usr/lib/libstdc++.so.6; echo "[ok] libstdc++.so.6 -> $(basename $REALSTD)"
else echo "[WARN] libstdc++ asli LFS tidak ditemukan"; fi

# 5. apk: kosongkan db, nonaktifkan repo Alpine; pam.d/sudo tidak berguna (LFS tanpa PAM)
mv $DB $Q/apk-installed.db; : > $DB
sed -i 's|^\([^#]\)|# \1|' $L/etc/apk/repositories
rm -f $L/etc/pam.d/sudo

# 6. laporan
echo; echo "== symlink rusak di /usr/lib =="
find $L/usr/lib -maxdepth 1 -xtype l | sed "s|^$L||"
echo; echo "== OpenSSL / libgcc_s sekarang =="
ls -l $L/usr/lib/libcrypto.so* $L/usr/lib/libssl.so* $L/usr/lib/libgcc_s.so* 2>&1 | sed "s|$L||"
grep -E 'define OPENSSL_VERSION_(STR|TEXT)' $L/usr/include/openssl/opensslv.h 2>&1
grep -h '^Version' $L/usr/lib/pkgconfig/openssl.pc 2>&1
echo; echo "== sumber libgcc_s di LFS =="
find $L -xdev -name 'libgcc_s.so*' 2>/dev/null | sed "s|^$L||"
ls $L/tools 2>&1 | head -3
echo; echo "== gcc =="
$CH 'gcc -dumpfullversion; echo "int main(void){return 0;}" > /tmp/t.c && gcc /tmp/t.c -o /tmp/t && /tmp/t && echo GCC-OK; rm -f /tmp/t /tmp/t.c'
echo; echo "== library yang masih hilang untuk program penting =="
for b in /usr/sbin/sshd /usr/sbin/nginx /usr/bin/login /usr/bin/su /usr/bin/fastfetch /usr/bin/bash; do
  printf '%s: ' $b; $CH "ldd $b 2>&1 | grep -E 'not found|musl' | tr -s ' \n' ' '"; echo
done
echo "== selesai =="
