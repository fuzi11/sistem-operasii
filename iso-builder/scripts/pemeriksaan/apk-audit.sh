#!/bin/bash
L=/mnt/lfs
DB=$L/lib/apk/db/installed
[ -f $DB ] || { echo "db apk tidak ada"; exit 1; }

echo "== 1. file milik apk yang masih ada dan berbasis musl =="
awk -F: '/^F:/{d=$2} /^R:/{print d"/"$2}' $DB | sed 's|^/||' | while read -r p; do
  f="$L/$p"
  [ -f "$f" ] && [ ! -L "$f" ] || continue
  if readelf -d "$f" 2>/dev/null | grep -q 'libc.musl' || file -b "$f" | grep -q 'interpreter /lib/ld-musl'; then echo "MUSL  /$p"; fi
done

echo; echo "== 2. library kunci: asli glibc atau musl? =="
for x in libz.so.1 libcrypto.so.3 libssl.so.3 libgcc_s.so.1 libstdc++.so.6 libncursesw.so.6 libatomic.so.1 libidn2.so.0 libunistring.so.5 libbrotlicommon.so.1 libnghttp2.so.14 libcurl.so.4; do
  f=$L/usr/lib/$x
  if [ -e "$f" ]; then
    r=$(readlink -f "$f" | sed "s|^$L||")
    if readelf -d "$f" 2>/dev/null | grep -q 'libc.musl'; then s=MUSL; else s=glibc; fi
    printf '%-22s %-6s %s\n' $x $s "$r"
  else printf '%-22s TIDAK ADA\n' $x; fi
done

echo; echo "== 3. program penting: interpreter =="
for b in bash sh login su passwd chpasswd useradd agetty systemctl sshd nginx sudo visudo; do
  f=$(ls $L/usr/bin/$b $L/usr/sbin/$b 2>/dev/null | head -1)
  if [ -n "$f" ]; then printf '%-10s %-34s %s\n' $b "$(readlink -f "$f" | sed "s|^$L||")" "$(file -L "$f" | grep -o 'interpreter [^,]*')"
  else printf '%-10s TIDAK ADA\n' $b; fi
done
ls -l $L/bin/sh 2>&1

echo; echo "== 4. symlink busybox =="
find $L/usr/bin $L/usr/sbin -lname '*busybox*' 2>/dev/null | sed "s|^$L||" | tr '\n' ' '; echo

echo; echo "== 5. hash password (hanya awalan) =="
awk -F: '$2 ~ /^\$/ {print $1, substr($2,1,3)}' $L/etc/shadow
grep -E '^ENCRYPT_METHOD' $L/etc/login.defs

echo; echo "== 6. source tarball di LFS =="
ls $L/sources 2>/dev/null | wc -l
ls $L/sources 2>/dev/null | grep -iE 'zlib|openssl|gcc|sudo|ncurses|glibc|xcrypt|shadow' | head -20
echo "== selesai =="
