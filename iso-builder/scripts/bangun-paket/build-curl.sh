#!/bin/bash
set -e
L=/mnt/lfs
mountpoint -q $L || { echo "STOP: sda2 belum ter-mount"; exit 1; }
F=$(wget -qO- https://curl.se/download/ | grep -oE 'curl-[0-9]+\.[0-9]+\.[0-9]+\.tar\.xz' | sort -uV | tail -1)
[ -n "$F" ] || { echo "STOP: gagal membaca daftar rilis curl (cek internet)"; exit 1; }
V=${F%.tar.xz}
echo "[info] versi curl: $V"
[ -f $L/sources/$F ] || wget -O $L/sources/$F https://curl.se/download/$F
tar tJf $L/sources/$F >/dev/null || { echo "STOP: tarball rusak"; exit 1; }
mkdir -p $L/etc/ssl/certs
[ -s $L/etc/ssl/certs/ca-certificates.crt ] || { cp /etc/ssl/certs/ca-certificates.crt $L/etc/ssl/certs/; echo "[fix] CA bundle disalin dari host"; }
[ -e $L/etc/ssl/cert.pem ] || ln -s certs/ca-certificates.crt $L/etc/ssl/cert.pem
mount --bind /dev $L/dev; mount -t proc proc $L/proc; mount -t sysfs sysfs $L/sys; mount -t tmpfs tmpfs $L/run
trap 'umount $L/run $L/sys $L/proc $L/dev 2>/dev/null' EXIT
chroot $L /usr/bin/env -i HOME=/root TERM=xterm PATH=/usr/sbin:/usr/bin V=$V /usr/bin/bash -e <<'EOF'
cd /sources
rm -rf $V; tar xf $V.tar.xz; cd $V
./configure --prefix=/usr --disable-static --with-openssl \
            --with-ca-bundle=/etc/ssl/certs/ca-certificates.crt \
            --without-libpsl --without-libidn2 --without-nghttp2 \
            --without-brotli --without-zstd --disable-docs
make -j$(nproc)
make install
ldconfig
cd /sources && rm -rf $V
EOF
echo; echo "== verifikasi curl =="
chroot $L /usr/bin/env -i PATH=/usr/sbin:/usr/bin /usr/bin/bash <<'EOF'
curl --version | head -2
ldd /usr/bin/curl | grep -E 'not found|musl' && exit 1 || echo "ldd-curl-ok"
echo "-- uji HTTPS:"; curl -sI --max-time 20 https://letsencrypt.org | head -1
EOF
echo "== selesai build-curl =="
