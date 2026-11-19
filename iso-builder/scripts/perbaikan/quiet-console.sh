#!/bin/bash
set -e
L=/mnt/lfs
IB=/root/iso-builder
mountpoint -q $L || { echo "STOP: sda2 belum ter-mount"; exit 1; }

mkdir -p $L/etc/sysctl.d
printf '%s\n' '# WebForge OS: sembunyikan log kernel dari konsol' 'kernel.printk = 3 4 1 3' > $L/etc/sysctl.d/20-webforge-printk.conf
mkdir -p $L/etc/systemd/journald.conf.d
printf '%s\n' '[Journal]' 'ForwardToConsole=no' 'RuntimeMaxUse=16M' > $L/etc/systemd/journald.conf.d/10-webforge.conf
echo "[ok] sysctl dan journald"

cat > $IB/WebForgeOS/boot/grub/grub.cfg <<'EOF'
set timeout=10
set default=0

menuentry "WebForge OS - Live" {
    linux /boot/vmlinuz quiet loglevel=3 console=tty0 webforge.mode=live
    initrd /boot/initrd.img
}
menuentry "WebForge OS - Install (TUI / layar biru)" {
    linux /boot/vmlinuz quiet loglevel=3 console=tty0 webforge.mode=install-tui
    initrd /boot/initrd.img
}
menuentry "WebForge OS - Install (CLI)" {
    linux /boot/vmlinuz quiet loglevel=3 console=tty0 webforge.mode=install-cli
    initrd /boot/initrd.img
}
menuentry "WebForge OS - Live (tampilan aman / nomodeset)" {
    linux /boot/vmlinuz quiet loglevel=3 console=tty0 nomodeset vga=normal webforge.mode=live
    initrd /boot/initrd.img
}
menuentry "WebForge OS - Live (log lengkap / debug)" {
    linux /boot/vmlinuz loglevel=7 console=tty0 webforge.mode=live
    initrd /boot/initrd.img
}
EOF
echo "[ok] grub.cfg ISO: $(grep -c 'quiet loglevel=3' $IB/WebForgeOS/boot/grub/grub.cfg) menu quiet, 1 menu debug"

python3 - <<'PYEOF'
p = '/mnt/lfs/usr/sbin/webforge-install'
s = open(p).read()
old = 'rootwait ro console=tty0 loglevel=4'
new = 'rootwait ro quiet console=tty0 loglevel=3'
if new in s:
    print('[patch] installer sudah dipatch, dilewati')
elif s.count(old) == 1:
    open(p, 'w').write(s.replace(old, new))
    print('[patch] installer: GRUB sistem terinstal memakai quiet loglevel=3')
else:
    raise SystemExit('STOP: pola tidak ditemukan persis 1x (%d), installer tidak diubah' % s.count(old))
PYEOF
bash -n $L/usr/sbin/webforge-install && echo "[ok] sintaks installer"
echo "== selesai quiet-console =="
