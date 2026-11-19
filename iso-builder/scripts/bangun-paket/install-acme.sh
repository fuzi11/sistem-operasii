#!/bin/bash
set -e
L=/mnt/lfs
CH="chroot $L /usr/bin/env -i HOME=/root TERM=xterm PATH=/usr/sbin:/usr/bin /usr/bin/bash"
mountpoint -q $L || { echo "STOP: sda2 belum ter-mount"; exit 1; }
$CH -c 'command -v curl >/dev/null || command -v wget >/dev/null' || { echo "STOP: curl/wget belum ada di LFS"; exit 1; }
wget -O $L/sources/acme.sh.tar.gz https://github.com/acmesh-official/acme.sh/archive/refs/heads/master.tar.gz
tar tzf $L/sources/acme.sh.tar.gz >/dev/null || { echo "STOP: tarball rusak"; exit 1; }
mount --bind /dev $L/dev; mount -t proc proc $L/proc; mount -t sysfs sysfs $L/sys; mount -t tmpfs tmpfs $L/run
trap 'umount $L/run $L/sys $L/proc $L/dev 2>/dev/null' EXIT
$CH -e <<'EOF'
cd /sources
rm -rf acme.sh-master; tar xf acme.sh.tar.gz
cd acme.sh-master
./acme.sh --install --home /root/.acme.sh --nocron --noprofile --auto-upgrade 0
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
cd /sources && rm -rf acme.sh-master acme.sh.tar.gz
EOF
echo; echo "== verifikasi acme.sh =="
$CH <<'EOF'
ls -ld /root/.acme.sh; ls /root/.acme.sh | head
/root/.acme.sh/acme.sh --version | tail -2
grep -E 'DEFAULT_ACME_SERVER|AUTO_UPGRADE' /root/.acme.sh/account.conf
EOF
echo "== selesai install-acme =="
