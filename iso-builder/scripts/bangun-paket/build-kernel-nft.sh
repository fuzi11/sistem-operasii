#!/bin/bash
set -e
L=/mnt/lfs
CONF=$L/boot/config-7.1.8-live
CH="chroot $L /usr/bin/env -i HOME=/root TERM=xterm PATH=/usr/sbin:/usr/bin /usr/bin/bash"
mountpoint -q $L || { echo "STOP: sda2 belum ter-mount"; exit 1; }
[ -f $CONF ] && [ -f $L/boot/vmlinuz-webforge-live ] || { echo "STOP: config/kernel live tidak ada di /boot"; exit 1; }
if grep -qE '^CONFIG_NF_TABLES=(y|m)' $CONF; then
  echo "STOP: kernel sudah punya nf_tables, build tidak diperlukan. Masalah firewall ada di tempat lain."; exit 1
fi
echo "[info] nf_tables belum ada di kernel, lanjut build"
avail=$(df --output=avail -BG $L | tail -1 | tr -dc 0-9)
[ "$avail" -ge 8 ] || { echo "STOP: ruang di sda2 kurang ($avail GB, butuh >= 8)"; exit 1; }
$CH -c 'command -v modprobe depmod' >/dev/null || { echo "STOP: kmod (modprobe/depmod) tidak ada di LFS"; exit 1; }

cp $L/boot/vmlinuz-webforge-live /root/vmlinuz-webforge-live.sebelum-nft
cp $CONF /root/config-7.1.8-live.sebelum-nft
echo "[backup] kernel dan config lama ada di /root (*.sebelum-nft)"

[ -f $L/sources/linux-7.1.8.tar.xz ] || wget -O $L/sources/linux-7.1.8.tar.xz https://cdn.kernel.org/pub/linux/kernel/v7.x/linux-7.1.8.tar.xz
tar tJf $L/sources/linux-7.1.8.tar.xz >/dev/null || { echo "STOP: tarball rusak"; exit 1; }

mount --bind /dev $L/dev; mount -t proc proc $L/proc; mount -t sysfs sysfs $L/sys; mount -t tmpfs tmpfs $L/run
trap 'umount $L/run $L/sys $L/proc $L/dev 2>/dev/null' EXIT

$CH -e <<'EOF'
cd /sources
rm -rf linux-7.1.8; tar xf linux-7.1.8.tar.xz; cd linux-7.1.8
make mrproper
cp /boot/config-7.1.8-live .config
scripts/config -e NETFILTER_NETLINK -e NF_TABLES -e NF_TABLES_INET -e NF_TABLES_IPV4 -e NF_TABLES_IPV6 -e NF_TABLES_NETDEV \
  -e NFT_CT -e NFT_COUNTER -e NFT_LIMIT -e NFT_LOG -e NFT_REJECT -e NFT_REJECT_INET -e NFT_NAT -e NFT_MASQ -e NFT_REDIR \
  -e NFT_FIB -e NFT_FIB_INET -e NFT_FIB_IPV4 -e NFT_FIB_IPV6 -e NFT_HASH -e NFT_NUMGEN -e NFT_CONNLIMIT -e NFT_QUOTA \
  -e NFT_OSF -e NFT_SYNPROXY -e NFT_COMPAT -e NF_NAT -e NF_CONNTRACK
make olddefconfig
echo "== hasil konfigurasi =="
grep -E '^CONFIG_(NF_TABLES|NFT_)' .config | tr '\n' ' '; echo
grep -qE '^CONFIG_NF_TABLES=(y|m)' .config || { echo "[GAGAL] NF_TABLES tidak aktif di .config"; exit 1; }
for k in LOCALVERSION SQUASHFS OVERLAY_FS E1000 VMXNET3 R8169 TMPFS; do grep -E "^CONFIG_$k" .config | head -1; done
REL=$(make -s kernelrelease)
echo "kernel.release = $REL"
[ "$REL" = "7.1.8-live" ] || { echo "[GAGAL] kernel.release harus 7.1.8-live"; exit 1; }
make -j$(nproc)
make modules_install
cp -v arch/x86/boot/bzImage /boot/vmlinuz-webforge-live
cp -v .config /boot/config-7.1.8-live
ls -lh /boot/vmlinuz-webforge-live
cd /sources && rm -rf linux-7.1.8
EOF
rm -f $L/sources/linux-7.1.8.tar.xz
echo; echo "== verifikasi =="
ls -lh $L/boot/vmlinuz-webforge-live
grep -cE '^CONFIG_NF_TABLES=(y|m)' $L/boot/config-7.1.8-live | sed 's/^/NF_TABLES aktif (harus 1): /'
ls $L/lib/modules
find $L/lib/modules/7.1.8-live -name 'nft_*.ko*' | wc -l | sed 's/^/modul nft_* terpasang: /'
ls $L/sources
echo "== selesai build-kernel-nft =="
