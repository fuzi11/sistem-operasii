#!/bin/bash
L=/mnt/lfs
Q=/root/apk-quarantine
mountpoint -q $L || { echo "STOP: sda2 belum ter-mount"; exit 1; }
[ -e $L/boot/config-7.1.8-live ] && [ -e $L/boot/vmlinuz-webforge-live ] || { echo "STOP: kernel/config live tidak ada di /boot, source kernel jangan dihapus"; exit 1; }
HAPUS=0; [ "$1" = "--hapus" ] && HAPUS=1

LIST=$(mktemp)
# --- apk: binary, library, konfigurasi, database, cache, rootfs Alpine ---
for p in usr/bin/apk usr/sbin/apk sbin/apk bin/apk usr/local/bin/apk usr/local/sbin/apk \
         etc/apk usr/lib/apk var/lib/apk var/cache/apk usr/share/apk opt/alpine; do
  [ -e "$L/$p" ] || [ -L "$L/$p" ] && echo "$p"
done > $LIST
find $L/usr/lib $L/usr/include $L/usr/share/man $L/usr/share/bash-completion $L/usr/share/zsh $L/usr/share/doc $L/usr/local \
  \( -path '*/python3*' -prune \) -o \
  \( -name 'libapk*' -o -name 'apk.pc' -o -name '_apk' -o -name 'apk.1*' -o -name 'apk.5*' -o -name 'apk.8*' -o -name 'apk-*' -o -name 'apk_*' \) -print 2>/dev/null | sed "s|^$L/||" >> $LIST
# symlink busybox/apk yatim
find $L/usr/bin $L/usr/sbin -maxdepth 1 -lname '*apk*' 2>/dev/null | sed "s|^$L/||" >> $LIST
sort -u $LIST -o $LIST

# --- source kernel di /sources ---
KS=$(ls -d $L/sources/linux-* $L/sources/build-live*.log 2>/dev/null | sed "s|^$L/||")

echo "== yang terkait apk =="
while read -r p; do [ -n "$p" ] && printf '%8s  /%s\n' "$(du -sh "$L/$p" 2>/dev/null | cut -f1)" "$p"; done < $LIST
echo; echo "== source kernel di /sources =="
for p in $KS; do printf '%8s  /%s\n' "$(du -sh "$L/$p" | cut -f1)" "$p"; done
echo; echo "== symlink modul kernel yang akan putus =="
find $L/lib/modules -maxdepth 2 -type l 2>/dev/null | sed "s|^$L||"
echo; echo "== referensi apk di skrip/unit/halaman (TIDAK diubah, untuk langkah berikutnya) =="
grep -rIl -w 'apk' $L/usr/local $L/usr/bin/webforge* $L/usr/sbin/webforge* $L/etc/webforge* $L/usr/lib/webforge \
   $L/etc/systemd $L/var/www $L/usr/share/nginx $L/etc/nginx $L/etc/profile.d $L/etc/skel 2>/dev/null | sed "s|^$L||" | head -30

if [ $HAPUS = 0 ]; then
  echo; echo ">> Mode lihat saja. Jalankan ulang dengan:  ~/iso-builder/remove-apk.sh --hapus"
  rm -f $LIST; exit 0
fi

echo; echo "== backup lalu hapus =="
mkdir -p $Q
( cd $L && tar czf $Q/apk-files.tgz -T $LIST 2>/dev/null )
cp $L/boot/config-7.1.8-live ~/iso-builder/config-7.1.8-live.bak
echo "[backup] $Q/apk-files.tgz ($(du -h $Q/apk-files.tgz | cut -f1)), config kernel -> ~/iso-builder/config-7.1.8-live.bak"
while read -r p; do [ -n "$p" ] && rm -rf "$L/$p"; done < $LIST
for p in $KS; do rm -rf "$L/$p"; done
find $L/lib/modules -maxdepth 2 -xtype l -print -delete | sed "s|^$L||"
chroot $L /usr/bin/env -i PATH=/usr/sbin:/usr/bin /usr/bin/bash -c 'ldconfig; command -v apk || echo "apk: tidak ada (benar)"'
echo; echo "== sisa =="
ls /mnt/lfs/sources | head -20
du -sh /mnt/lfs/sources
find $L -xdev -name 'apk' 2>/dev/null | grep -v python | head
echo "== selesai remove-apk =="
rm -f $LIST
