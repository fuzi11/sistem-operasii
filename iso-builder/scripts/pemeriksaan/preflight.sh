#!/bin/bash
L=/mnt/lfs
CH="chroot $L /usr/bin/env -i PATH=/usr/sbin:/usr/bin /usr/bin/bash -c"
mountpoint -q $L || { echo "STOP: sda2 belum ter-mount"; exit 1; }
echo "== mount =="; mount | grep /mnt/lfs
echo "== apk sudah hilang? =="
$CH 'command -v apk || echo "apk: tidak ada (benar)"'
ls -d $L/etc/apk $L/opt/alpine $L/var/cache/apk 2>&1 | sed "s|$L||"
echo "== isi /sources =="; ls $L/sources
echo "== halaman web =="
F=$L/var/www/html/index.html
ls -l $F
echo -n "baris menyebut apk (harus 0): "; grep -ciw apk $F
echo "section buka / tutup (harus 4 / 4): $(grep -c '<section' $F) / $(grep -c '</section>' $F)"
echo "== CLI webforge dan acme.sh: alat yang dipakai =="
FILES=$(find $L/usr/local $L/usr/bin $L/usr/sbin $L/usr/lib/webforge $L/usr/libexec $L/root/.acme.sh $L/etc/webforge \( -name 'webforge*' -o -name 'acme.sh' \) -type f 2>/dev/null)
echo "$FILES" | sed "s|^$L||"
for t in curl wget which nc netstat nslookup route arp ipcalc unzip crontab cpio lsof whois tree ntpd traceroute6 time; do
  if [ -n "$FILES" ] && grep -qEwI "$t" $FILES 2>/dev/null; then
    printf '  dipakai: %-12s ' $t
    $CH "command -v $t" >/dev/null 2>&1 && echo ada || echo "TIDAK ADA"
  fi
done
echo "== kernel dan sudo =="
ls -l $L/boot/vmlinuz-webforge-live
$CH 'sudo -V | head -1; visudo -c | tail -1'
df -h /root | tail -1
echo "== selesai preflight =="
