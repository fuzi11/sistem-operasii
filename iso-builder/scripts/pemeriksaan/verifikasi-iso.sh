#!/bin/bash
IB=/root/iso-builder
ISO=$IB/WebForgeOS.iso
SQ=$IB/WebForgeOS/live/filesystem.squashfs
[ -f $ISO ] && [ -f $SQ ] || { echo "ISO belum ada. Jalankan build dulu."; exit 1; }
LIST=$(unsquashfs -ll $SQ 2>/dev/null)
echo "=============================================="
echo " VERIFIKASI ISO WEBFORGE OS"
echo "=============================================="
echo "Berkas  : $ISO"
echo "Ukuran  : $(du -h $ISO | cut -f1)"
echo "Dibuat  : $(date -r $ISO '+%Y-%m-%d %H:%M:%S')"
echo "SHA-256 : $(sha256sum $ISO | cut -d' ' -f1)"
echo
bad=0
chk() { if echo "$LIST" | grep -qE "squashfs-root/$1( |\$)"; then echo "[ok]    ada    : $1"; else echo "[GAGAL] hilang : $1"; bad=1; fi; }
for p in usr/bin/curl usr/bin/sudo root/.acme.sh/acme.sh usr/sbin/webforge-install usr/sbin/webforge-tty1 \
         usr/bin/webforge usr/lib/webforge/modules/help.sh usr/lib/webforge/help.tsv \
         etc/systemd/system/webforge-quiet-console.service etc/systemd/journald.conf.d/10-webforge.conf \
         usr/share/webforge/logo.txt var/www/html/index.html; do chk "$p"; done
n=$(echo "$LIST" | grep -cE 'ld-musl|squashfs-root/opt/alpine|squashfs-root/etc/apk|squashfs-root/usr/bin/apk( |$)' || true)
[ "$n" = 0 ] && echo "[ok]    tanpa musl dan apk" || { echo "[GAGAL] sisa musl/apk: $n"; bad=1; }
n=$(echo "$LIST" | grep -cE 'squashfs-root/root/\.acme\.sh/.*\.key' || true)
[ "$n" = 0 ] && echo "[ok]    tanpa kunci privat acme" || { echo "[GAGAL] kunci acme ikut: $n"; bad=1; }
n=$(grep -c '^menuentry' $IB/WebForgeOS/boot/grub/grub.cfg)
[ "$n" = 3 ] && echo "[ok]    menu GRUB: 3 entri (Live, Install TUI, Install CLI)" || { echo "[GAGAL] jumlah menu = $n (harus 3)"; bad=1; }
echo
[ "$bad" = 0 ] && echo "HASIL: SEMUA PEMERIKSAAN LULUS" || echo "HASIL: ADA YANG GAGAL"
