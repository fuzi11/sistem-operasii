#!/bin/bash
set -e
L=/mnt/lfs
IB=/root/iso-builder
mountpoint -q $L || { echo "STOP: sda2 belum ter-mount"; exit 1; }
chroot $L /usr/bin/env -i PATH=/usr/sbin:/usr/bin /usr/bin/bash -c 'command -v dmesg' >/dev/null || { echo "STOP: dmesg tidak ada di LFS"; exit 1; }

echo "== 1. service: sembunyikan log setelah boot selesai =="
rm -f $L/etc/sysctl.d/20-webforge-printk.conf
cat > $L/etc/systemd/system/webforge-quiet-console.service <<'EOF'
[Unit]
Description=Sembunyikan log kernel di konsol setelah boot selesai
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/bin/dmesg -n 3

[Install]
WantedBy=multi-user.target
EOF
mkdir -p $L/etc/systemd/system/multi-user.target.wants
ln -sf /etc/systemd/system/webforge-quiet-console.service $L/etc/systemd/system/multi-user.target.wants/webforge-quiet-console.service
ls -l $L/etc/systemd/system/webforge-quiet-console.service $L/etc/systemd/system/multi-user.target.wants/webforge-quiet-console.service | sed "s|$L||"

echo "== 2. menu GRUB ISO: 3 entri =="
cat > $IB/WebForgeOS/boot/grub/grub.cfg <<'EOF'
set timeout=10
set default=0

menuentry "WebForge OS - Live" {
    linux /boot/vmlinuz console=tty0 loglevel=7 webforge.mode=live
    initrd /boot/initrd.img
}
menuentry "WebForge OS - Install (TUI / layar biru)" {
    linux /boot/vmlinuz console=tty0 loglevel=7 webforge.mode=install-tui
    initrd /boot/initrd.img
}
menuentry "WebForge OS - Install (CLI)" {
    linux /boot/vmlinuz console=tty0 loglevel=7 webforge.mode=install-cli
    initrd /boot/initrd.img
}
EOF
echo "[ok] entri menu: $(grep -c '^menuentry' $IB/WebForgeOS/boot/grub/grub.cfg), 'quiet' tersisa: $(grep -c quiet $IB/WebForgeOS/boot/grub/grub.cfg || true)"

echo "== 3. installer: GRUB sistem terinstal =="
python3 - <<'PYEOF'
p = '/mnt/lfs/usr/sbin/webforge-install'
s = open(p).read()
old = 'rootwait ro quiet console=tty0 loglevel=3'
new = 'rootwait ro console=tty0 loglevel=7'
if new in s:
    print('[patch] installer sudah memakai loglevel=7, dilewati')
elif s.count(old) == 1:
    open(p, 'w').write(s.replace(old, new))
    print('[patch] installer: sistem terinstal memakai loglevel=7 (tanpa quiet)')
else:
    raise SystemExit('STOP: pola tidak ditemukan persis 1x (%d), installer tidak diubah' % s.count(old))
PYEOF
bash -n $L/usr/sbin/webforge-install && echo "[ok] sintaks installer"

echo "== 4. sesuaikan verifikasi-iso.sh =="
python3 - <<'PYEOF'
import os
p = os.path.expanduser('~/iso-builder/verifikasi-iso.sh')
s = open(p).read()
old = ("n=$(grep -c 'quiet loglevel=3' $IB/WebForgeOS/boot/grub/grub.cfg)\n"
       "[ \"$n\" = 4 ] && echo \"[ok]    menu GRUB: 4 menu quiet + 1 menu debug\" || { echo \"[GAGAL] menu quiet = $n (harus 4)\"; bad=1; }\n")
new = ("n=$(grep -c '^menuentry' $IB/WebForgeOS/boot/grub/grub.cfg)\n"
       "[ \"$n\" = 3 ] && echo \"[ok]    menu GRUB: 3 entri (Live, Install TUI, Install CLI)\" || { echo \"[GAGAL] jumlah menu = $n (harus 3)\"; bad=1; }\n")
if new in s:
    print('[skip] verifikasi sudah disesuaikan')
elif s.count(old) == 1:
    s = s.replace(old, new)
    s = s.replace('etc/sysctl.d/20-webforge-printk.conf', 'etc/systemd/system/webforge-quiet-console.service')
    open(p, 'w').write(s)
    print('[ok] verifikasi-iso.sh disesuaikan')
else:
    print('[warn] pola verifikasi tidak cocok, file tidak diubah')
PYEOF
bash -n ~/iso-builder/verifikasi-iso.sh && echo "[ok] sintaks verifikasi-iso.sh"
echo "== selesai ubah-boot-log =="
