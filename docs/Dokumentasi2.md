# WebForge OS (13.1-systemd) - Technical Documentation

**WebForge OS** adalah distribusi Linux kustom independen yang dibangun berbasiskan **Linux From Scratch (LFS 13.1-systemd)**. OS ini dirancang khusus sebagai sistem operasi *web server* yang super ringan, efisien dalam penggunaan RAM, serta dioptimalkan untuk lingkungan virtualisasi (VMware / KVM / VirtIO) dengan manajemen otomatis penuh melalui SSH dan `systemd`.

---

## 1. Spesifikasi Sistem & Arsitektur

| Komponen | Spesifikasi / Teknologi |
| :--- | :--- |
| **Base System** | Linux From Scratch (LFS) 13.1 (systemd) |
| **Kernel Linux** | Version 7.1.8 (Custom Minimalist Build) |
| **Init System** | `systemd` (PID 1) |
| **Network Manager** | `systemd-networkd` + `systemd-resolved` |
| **Time Sync** | `systemd-timesyncd` |
| **Remote Access** | OpenSSH 9.8p1 |
| **Web Stack Target** | Nginx 1.26.2 + PHP 8.3 + SQLite / MariaDB |
| **System Info Fetch**| Fastfetch + Chafa (Custom ASCII/Image Renderer) |
| **Target Media** | Virtual Machine (VMware Workstation Pro / ESXi) |

---

## 2. Optimasi Kernel Linux (v7.1.8)

Kernel dikompilasi secara selektif dengan membuang modul yang tidak diperlukan untuk *server* (seperti Wi-Fi, Bluetooth, Audio, dan Driver GPU berat) untuk menekan *footprint* RAM dan mempercepat waktu *booting*.

### Driver Jaringan & Virtualisasi yang Diaktifkan
* **`CONFIG_PCI`** & **`CONFIG_NETDEVICES`**
* **`CONFIG_NET_ETHERNET`**
* **Intel NICs:** `CONFIG_NET_VENDOR_INTEL`, `CONFIG_E1000`, `CONFIG_E1000E`
* **VMware Virtual NICs:** `CONFIG_NET_VENDOR_VMWARE`, `CONFIG_VMXNET3`
* **AMD / PCNet:** `CONFIG_NET_VENDOR_AMD`, `CONFIG_PCNET32`
* **KVM / VirtIO:** `CONFIG_VIRTIO_NET`

### Perintah Kustomisasi Kernel (One-Liner)
```bash
./scripts/config --enable CONFIG_PCI \
                 --enable CONFIG_NETDEVICES \
                 --enable CONFIG_NET_ETHERNET \
                 --enable CONFIG_NET_VENDOR_INTEL \
                 --enable CONFIG_NET_VENDOR_VMWARE \
                 --enable CONFIG_NET_VENDOR_AMD \
                 --enable CONFIG_E1000 \
                 --enable CONFIG_E1000E \
                 --enable CONFIG_VMXNET3 \
                 --enable CONFIG_PCNET32 \
                 --enable CONFIG_VIRTIO_NET
make olddefconfig
make -j$(nproc)

