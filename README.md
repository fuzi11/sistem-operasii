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

## Dokumentasi Bab 3 - Packages and Patches (Selesai)
- Storage Directory: `/mnt/lfs/sources`
- Permissions: Sticky bit `a+wt`
- Base Packages: 88 tarball kode sumber
- Patches: 8 berkas patch resmi LFS 13.1
- Custom Package: Nginx 1.26.2 (Web Server Distro)
- Integrity Status: 100% Verified via `md5sum -c md5sums`
- File Ownership: `root:root`

## Dokumentasi Bab 4.2 - Creating a Limited Directory Layout
- Base Directories: `/etc`, `/var`, `/usr/bin`, `/usr/lib`, `/usr/sbin`
- Merged /usr Symlinks: `/bin` -> `usr/bin`, `/lib` -> `usr/lib`, `/sbin` -> `usr/sbin`
- Architecture Directory: `/lib64` created (x86_64)
- Temporary Tools Directory: `/mnt/lfs/tools`
- Script Executed: `01-prepare-directory-layout.sh`

## Dokumentasi Bab 4.3 - Adding the LFS User
- Created Group: `lfs`
- Created User: `lfs` (Shell: `/bin/bash`, Home: `/home/lfs`, Skeleton: `/dev/null`)
- Permissions Transferred: Owner of `$LFS/usr`, `$LFS/var`, `$LFS/etc`, `$LFS/tools`, `$LFS/sources`, and `$LFS/lib64` set to `lfs:lfs`
- User Shell Verification: Switched session via `su - lfs`
- Script Executed: `02-add-lfs-user.sh`

## Dokumentasi Bab 4 - Final Preparations (Selesai)
- Limited Directory Layout: Created `/mnt/lfs/{etc,var,tools,lib64}` and merged `/usr` symlinks
- Build User: `lfs` user and group created
- Permissions: Ownership of `$LFS` subdirectories assigned to `lfs`
- Host Protection: Neutralized `/etc/bash.bashrc` to `/etc/bash.bashrc.NOUSE`
- Environment Isolation: Configured `~/.bash_profile` and `~/.bashrc`
- Parallel Build: Enabled `MAKEFLAGS=-j$(nproc)` for multi-core compilation


