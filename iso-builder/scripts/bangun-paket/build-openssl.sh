#!/bin/bash
set -e
L=/mnt/lfs
V=openssl-4.0.1
mountpoint -q $L || { echo "STOP: sda2 belum ter-mount"; exit 1; }
mkdir -p $L/sources
if [ ! -f $L/sources/$V.tar.gz ]; then
  wget -O $L/sources/$V.tar.gz https://github.com/openssl/openssl/releases/download/$V/$V.tar.gz \
    || wget -O $L/sources/$V.tar.gz https://www.openssl.org/source/$V.tar.gz
fi
tar tzf $L/sources/$V.tar.gz >/dev/null || { echo "STOP: tarball rusak"; exit 1; }

mount --bind /dev $L/dev; mount -t proc proc $L/proc; mount -t sysfs sysfs $L/sys; mount -t tmpfs tmpfs $L/run
trap 'umount $L/run $L/sys $L/proc $L/dev 2>/dev/null' EXIT

chroot $L /usr/bin/env -i HOME=/root TERM=$TERM PATH=/usr/sbin:/usr/bin /usr/bin/bash -e <<'EOF'
cd /sources
rm -rf openssl-4.0.1
tar xf openssl-4.0.1.tar.gz
cd openssl-4.0.1
./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib shared zlib-dynamic
make -j$(nproc)
sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
make MANSUFFIX=ssl install
ldconfig
cd /sources && rm -rf openssl-4.0.1
EOF

echo; echo "== verifikasi =="
chroot $L /usr/bin/env -i PATH=/usr/sbin:/usr/bin /usr/bin/bash -c '
openssl version
ls -l /usr/lib/libcrypto.so* /usr/lib/libssl.so*
for b in /usr/sbin/sshd /usr/sbin/nginx /usr/bin/openssl; do
  printf "%s: " $b; ldd $b 2>&1 | grep -E "not found|musl" | tr -s " \n" " "; echo
done'
echo "== selesai build-openssl =="
