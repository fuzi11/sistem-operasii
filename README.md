## Dokumentasi Bab 2 - Pempartisian Sistem
- Host OS: Ubuntu 22.04 LTS (20 GB - /dev/sda1)
- Target LFS Partition: 30 GB (/dev/sda2)
- File System Target: ext4

## Dokumentasi Bab 2.5 - Pemformatan Sistem File
- Partisi Target: /dev/sda2
- Tipe File System: ext4
- Perintah Format: `mkfs -v -t ext4 /dev/sda2`
- Status: Selesai diformat dan siap digunakan.

## Dokumentasi Bab 2.6 - Variabel Lingkungan & Umask
- Location Variable ($LFS): /mnt/lfs
- Umask Permission: 022 (Default permission mode 644/755)
- Persistence: Dikonfigurasi di ~/.bashrc (User & Root)

## Dokumentasi Bab 2.7 - Mounting Partisi LFS
- Mount Point: /mnt/lfs ($LFS)
- Target Device: /dev/sda2
- Permissions: root:root (755)
- Auto-mount: Dikonfigurasi pada /etc/fstab host Ubuntu

*Bab 2 (Preparing the Host System) Selesai sepenuhnya.*

## Dokumentasi Bab 3.1 - Download Packages
- Directory Target: `/mnt/lfs/sources`
- Sticky Bit Permission: `a+wt`
- Manifest File: Generated `wget-list-systemd` locally
- Total Packages: ~80 paket dasar LFS + Nginx 1.26.2
- File Ownership: `root:root`


