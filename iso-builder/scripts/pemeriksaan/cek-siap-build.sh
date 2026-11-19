#!/bin/bash
L=/mnt/lfs; IB=/root/iso-builder; bad=0
t() { if [ "$1" = ok ]; then echo "[ok]    $2"; else echo "[BELUM] $2   -> $3"; bad=1; fi; }
grep -q '^CONFIG_NF_TABLES=y' $L/boot/config-7.1.8-live && r=ok || r=no;                       t $r "kernel punya nf_tables" "build-kernel-nft.sh"
[ "$(grep -c '^menuentry' $IB/WebForgeOS/boot/grub/grub.cfg)" = 3 ] && r=ok || r=no;         t $r "menu GRUB ISO = 3 entri" "ubah-boot-log.sh"
grep -q quiet $IB/WebForgeOS/boot/grub/grub.cfg && r=no || r=ok;                              t $r "menu GRUB tanpa 'quiet'" "ubah-boot-log.sh"
[ -f $L/etc/systemd/system/webforge-quiet-console.service ] && r=ok || r=no;                  t $r "service sembunyikan log setelah boot" "ubah-boot-log.sh"
grep -q 'rootwait ro console=tty0 loglevel=7' $L/usr/sbin/webforge-install && r=ok || r=no;   t $r "installer: sistem terinstal loglevel=7" "ubah-boot-log.sh"
grep -q _wf_help_lama $L/usr/lib/webforge/modules/help.sh && r=ok || r=no;                    t $r "help.sh: logika doctor dipertahankan" "patch-doctor.sh"
[ "$(awk -F'\t' '$1=="K"{n++} END{print n+0}' $L/usr/lib/webforge/help.tsv)" = 97 ] && r=ok || r=no; t $r "help.tsv = 97 perintah" "fix-firewall.sh"
grep -q 'enable)' $L/usr/lib/webforge/modules/fw.sh && grep -q 'disable)' $L/usr/lib/webforge/modules/fw.sh && r=ok || r=no; t $r "fw.sh punya enable dan disable" "fix-firewall.sh"
grep -q allowed_tcp $L/etc/nftables.conf && r=ok || r=no;                                     t $r "aturan firewall memakai set allowed_tcp" "fix-firewall.sh"
grep -q 'ExecStart=/usr/sbin/nft -f' $L/etc/systemd/system/nftables.service && r=ok || r=no;  t $r "unit nftables memanggil nft langsung" "fix-firewall.sh"
[ "$(grep -ciw apk $L/var/www/html/index.html)" = 0 ] && r=ok || r=no;                       t $r "halaman web tanpa apk" "-"
[ ! -e $L/usr/lib/ld-musl-x86_64.so.1 ] && [ ! -e $L/etc/apk ] && [ ! -e $L/opt/alpine ] && r=ok || r=no; t $r "LFS tanpa musl/apk" "-"
[ "$(mount | grep -c $L)" = 1 ] && r=ok || r=no;                                              t $r "tidak ada mount sisa di /mnt/lfs" "umount sisa mount"
[ "$(df --output=avail -BM /root | tail -1 | tr -dc 0-9)" -ge 1500 ] && r=ok || r=no;         t $r "ruang /root cukup (>= 1500 MB)" "hapus ISO/squashfs lama"
echo
[ $bad = 0 ] && echo "SIAP BUILD ISO" || echo "ADA YANG BELUM. Selesaikan dulu."
