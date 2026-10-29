#!/bin/bash
set -e

echo "Mulai Konfigurasi Jaringan (Section 9.2)..."

# 1. Konfigurasi systemd-networkd dengan DHCP
mkdir -pv /etc/systemd/network

cat > /etc/systemd/network/10-eth-dhcp.network << "EOF"
[Match]
Name=e*

[Network]
DHCP=ipv4

[DHCPv4]
UseDomains=true
EOF

# 2. Hostname Sistem
HOSTNAME="lfs-server"
echo "$HOSTNAME" > /etc/hostname
echo "[+] Hostname diatur ke: $HOSTNAME"

# 3. Berkas /etc/hosts
cat > /etc/hosts << EOF
# Begin /etc/hosts

127.0.0.1   localhost $HOSTNAME.localdomain $HOSTNAME
::1         ip6-localhost ip6-loopback
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters

# End /etc/hosts
EOF
echo "[+] Berkas /etc/hosts berhasil dibuat."

# 4. Berkas /etc/resolv.conf
cat > /etc/resolv.conf << "EOF"
# Begin /etc/resolv.conf

nameserver 8.8.8.8
nameserver 1.1.1.1

# End /etc/resolv.conf
EOF
echo "[+] Berkas DNS /etc/resolv.conf berhasil dibuat."

echo "Konfigurasi Jaringan Selesai!"