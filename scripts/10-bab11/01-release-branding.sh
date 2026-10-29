#!/bin/bash
set -e

OS_NAME="${DISTRO_NAME:-WebForge Os}"
OS_ID="${DISTRO_ID:-webforgeos}"
OS_CODENAME="${DISTRO_CODENAME:-wefor}"
OS_VER="13.1-systemd"

echo "=== Menerapkan Branding Distro (${OS_NAME} - ${OS_CODENAME}) ==="

# 1. /etc/lfs-release
echo "${OS_VER}" > /etc/lfs-release
echo "[+] /etc/lfs-release berhasil dikonfigurasi."

# 2. /etc/lsb-release
cat > /etc/lsb-release << EOF
DISTRIB_ID="${OS_NAME}"
DISTRIB_RELEASE="${OS_VER}"
DISTRIB_CODENAME="${OS_CODENAME}"
DISTRIB_DESCRIPTION="${OS_NAME} ${OS_VER} (${OS_CODENAME})"
EOF
echo "[+] /etc/lsb-release berhasil dikonfigurasi."

# 3. /etc/os-release
cat > /etc/os-release << EOF
NAME="${OS_NAME}"
VERSION="${OS_VER} (${OS_CODENAME})"
ID=${OS_ID}
PRETTY_NAME="${OS_NAME} ${OS_VER} (${OS_CODENAME} Edition)"
VERSION_CODENAME="${OS_CODENAME}"
HOME_URL="https://www.linuxfromscratch.org/lfs/"
RELEASE_TYPE="stable"
EOF
echo "[+] /etc/os-release berhasil dikonfigurasi."

# Cadangkan ke folder config/ jika ada
if [ -d "/config" ]; then
    cp -v /etc/lfs-release /config/lfs-release
    cp -v /etc/lsb-release /config/lsb-release
    cp -v /etc/os-release /config/os-release
fi

echo "=== Branding Distro Selesai ==="