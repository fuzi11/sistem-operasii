#!/bin/bash
set -e
L=/mnt/lfs
mountpoint -q $L || { echo "STOP: sda2 belum ter-mount"; exit 1; }
F=$(wget -qO- https://www.sudo.ws/dist/ | grep -oE 'sudo-[0-9]+\.[0-9]+\.[0-9]+(p[0-9]+)?\.tar\.gz' | sort -uV | tail -1)
[ -n "$F" ] || { echo "STOP: gagal membaca daftar rilis sudo (cek internet)"; exit 1; }
V=${F%.tar.gz}
echo "[info] versi sudo: $V"
[ -f $L/sources/$F ] || wget -O $L/sources/$F https://www.sudo.ws/dist/$F
tar tzf $L/sources/$F >/dev/null || { echo "STOP: tarball rusak"; exit 1; }

mount --bind /dev $L/dev; mount -t proc proc $L/proc; mount -t sysfs sysfs $L/sys; mount -t tmpfs tmpfs $L/run
trap 'umount $L/run $L/sys $L/proc $L/dev 2>/dev/null' EXIT

chroot $L /usr/bin/env -i HOME=/root TERM=xterm PATH=/usr/sbin:/usr/bin V=$V /usr/bin/bash -e <<'EOF'
cd /sources
rm -rf $V; tar xf $V.tar.gz; cd $V
./configure --prefix=/usr --libexecdir=/usr/lib --with-secure-path --with-env-editor \
            --without-pam --disable-openssl --with-passprompt="[sudo] password for %p: " \
            --docdir=/usr/share/doc/$V
make -j$(nproc)
make install
ln -sfv libsudo_util.so.0.0.0 /usr/lib/sudo/libsudo_util.so.0
ldconfig
cd /sources && rm -rf $V
EOF

# aturan sudo: grup wheel, password ROOT
mkdir -p $L/etc/sudoers.d
cat > $L/etc/sudoers.d/10-wheel <<'EOF'
%wheel ALL=(ALL:ALL) ALL
Defaults secure_path="/usr/sbin:/usr/bin"
Defaults rootpw
EOF
chmod 0440 $L/etc/sudoers.d/10-wheel
grep -qE '^[#@]includedir[[:space:]]+/etc/sudoers.d' $L/etc/sudoers || echo '@includedir /etc/sudoers.d' >> $L/etc/sudoers
chmod 0440 $L/etc/sudoers
rm -f $L/etc/pam.d/sudo

echo; echo "== verifikasi & uji =="
chroot $L /usr/bin/env -i PATH=/usr/sbin:/usr/bin /usr/bin/bash <<'EOF'
visudo -c
sudo -V | head -1
ldd /usr/bin/sudo | grep -E 'not found|musl' || echo "ldd-sudo-ok"
ls -l /usr/bin/sudo
getent group wheel >/dev/null || groupadd wheel
useradd -m -G wheel -s /bin/bash wftest
echo 'wftest:uji12345' | chpasswd
printf 'Defaults:wftest !rootpw\n' > /etc/sudoers.d/99-wftest; chmod 0440 /etc/sudoers.d/99-wftest
echo "-- password benar (harus 0):"
su -s /bin/bash wftest -c 'echo uji12345 | sudo -S -p "" id -u' 2>&1
echo "-- password salah (harus ditolak):"
su -s /bin/bash wftest -c 'echo salahsalah | sudo -S -k -p "" id -u' 2>&1 | tail -1
userdel -r wftest 2>/dev/null; rm -f /etc/sudoers.d/99-wftest
EOF
echo "== selesai build-sudo =="
