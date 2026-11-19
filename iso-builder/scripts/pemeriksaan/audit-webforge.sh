#!/bin/bash
L=/mnt/lfs
CH="chroot $L /usr/bin/env -i PATH=/usr/sbin:/usr/bin /usr/bin/bash -c"
mountpoint -q $L || { echo "STOP: sda2 belum ter-mount"; exit 1; }
CLI=$(find $L/usr/local $L/usr/bin $L/usr/sbin $L/opt -maxdepth 3 -name 'webforge' -type f 2>/dev/null | head -1)
echo "== lokasi =="; echo "CLI webforge : ${CLI:-TIDAK KETEMU}"
echo "acme.sh      :"; find $L/root $L/usr/local $L/opt $L/etc -maxdepth 3 -name 'acme.sh' 2>/dev/null | sed "s|^$L|  |"
SRC="$CLI $(find $L/usr/local/bin $L/usr/local/sbin $L/usr/local/lib $L/usr/lib/webforge $L/usr/libexec/webforge -type f 2>/dev/null)"
echo "berkas diperiksa:"; for f in $SRC; do echo "  ${f#$L}"; done
TOOLS="curl wget which nc ncat socat netstat nslookup dig host ping route arp ipcalc unzip crontab cpio lsof whois tree ntpd traceroute time htop btop nano vim rsync openssl ss ip nft jq htpasswd apk pgrep pkill killall logrotate update-ca-certificates python3 perl git fastfetch neofetch timedatectl hostnamectl chronyc"
echo; echo "== alat yang dipakai skrip tetapi TIDAK ADA di LFS =="
for t in $TOOLS; do
  $CH "command -v $t" >/dev/null 2>&1 && continue
  hits=$(grep -nEHw -- "$t" $SRC 2>/dev/null | grep -vE ':[0-9]+:[[:space:]]*#' | sed "s|$L||" | cut -c1-160 | head -4)
  [ -n "$hits" ] && { echo "--- $t"; echo "$hits"; }
done
echo; echo "== sertifikat CA (dibutuhkan untuk HTTPS) =="
ls -l $L/etc/ssl/certs/ca-certificates.crt $L/etc/ssl/cert.pem 2>&1 | sed "s|$L||"
echo; echo "== alat pendukung =="
for t in nano nft ip ss openssl rsync ssh sudo; do printf '%-8s' $t; $CH "command -v $t" 2>/dev/null || echo "-- TIDAK ADA"; done
echo "== selesai audit =="
