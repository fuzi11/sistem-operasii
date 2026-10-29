# Dokumentasi Linux From Scratch (LFS) 13.1 (Systemd)

## Bab 2 - Preparing the Host System

### 2.1 Pempartisian Sistem
- **Host OS:** Ubuntu 22.04 LTS (20 GB - `/dev/sda1`)
- **Target LFS Partition:** 30 GB (`/dev/sda2`)
- **File System Target:** ext4

### 2.5 Pemformatan Sistem File
- **Partisi Target:** `/dev/sda2`
- **Tipe File System:** ext4
- **Perintah Format:** `mkfs -v -t ext4 /dev/sda2`
- **Status:** Selesai diformat dan siap digunakan.

### 2.6 Variabel Lingkungan & Umask
- **Location Variable (`$LFS`):** `/mnt/lfs`
- **Umask Permission:** `022` (Default permission mode 644/755)
- **Persistence:** Dikonfigurasi di `~/.bashrc` (User & Root)

### 2.7 Mounting Partisi LFS
- **Mount Point:** `/mnt/lfs` (`$LFS`)
- **Target Device:** `/dev/sda2`
- **Permissions:** `root:root` (755)
- **Auto-mount:** Dikonfigurasi pada `/etc/fstab` host Ubuntu

> **Status:** Bab 2 (Preparing the Host System) selesai sepenuhnya.

---

## Bab 3 - Packages and Patches

- **Storage Directory:** `/mnt/lfs/sources`
- **Permissions:** Sticky bit `a+wt`
- **Base Packages:** 88 tarball kode sumber
- **Patches:** 8 berkas patch resmi LFS 13.1
- **Custom Package:** Nginx 1.26.2 (Web Server Distro)
- **Integrity Status:** 100% Verified via `md5sum -c md5sums`
- **File Ownership:** `root:root`

> **Status:** Bab 3 selesai sepenuhnya.

---

## Bab 4 - Final Preparations

### 4.2 Creating a Limited Directory Layout
- **Base Directories:** `/etc`, `/var`, `/usr/bin`, `/usr/lib`, `/usr/sbin`
- **Merged `/usr` Symlinks:** 
  - `/bin` -> `usr/bin`
  - `/lib` -> `usr/lib`
  - `/sbin` -> `usr/sbin`
- **Architecture Directory:** `/lib64` created (x86_64)
- **Temporary Tools Directory:** `/mnt/lfs/tools`
- **Script Executed:** `01-prepare-directory-layout.sh`

### 4.3 Adding the LFS User
- **Created Group:** `lfs`
- **Created User:** `lfs` (Shell: `/bin/bash`, Home: `/home/lfs`, Skeleton: `/dev/null`)
- **Permissions Transferred:** Ownership direktori `$LFS/usr`, `$LFS/var`, `$LFS/etc`, `$LFS/tools`, `$LFS/sources`, dan `$LFS/lib64` diubah ke `lfs:lfs`
- **User Shell Verification:** Switched session via `su - lfs`
- **Script Executed:** `02-add-lfs-user.sh`

### 4.4 Konfigurasi Lingkungan LFS User
- **Host Protection:** Neutralized `/etc/bash.bashrc` ke `/etc/bash.bashrc.NOUSE`
- **Environment Isolation:** Configured `~/.bash_profile` dan `~/.bashrc`
- **Parallel Build:** Enabled `MAKEFLAGS=-j$(nproc)` untuk multi-core compilation

> **Status:** Bab 4 (Final Preparations) selesai sepenuhnya.

---

## Bab 5 - Compiling a Cross-Toolchain

### 5.2 Binutils-2.47 (Pass 1)
- **Storage Directory:** `$LFS/sources`
- **Build Directory:** `$LFS/sources/binutils-2.47/build`
- **Target Directory:** `$LFS/tools`
- **Target Architecture:** `$LFS_TGT`
- **Primary Artifacts:** Cross-linker (`ld`) dan cross-assembler (`as`) awal

### 5.3 GCC-16.2.0 (Pass 1)
- **Embedded Packages:** `mpfr-4.2.2`, `gmp-6.3.0`, `mpc-1.4.1`
- **Target Directory:** `$LFS/tools`
- **Architecture Fix:** Sed patch pada `gcc/config/i386/t-linux64` untuk mengubah `lib64` ke `lib`
- **Primary Artifacts:** Cross-compiler C (`$LFS_TGT-gcc`) dan `libgcc` awal

### 5.4 Linux API Headers
- **Source Directory:** `$LFS/sources/linux-6.x`
- **Target Directory:** `$LFS/usr/include`
- **Pre-clean:** `make mrproper`
- **Primary Artifacts:** Header kernel ter-sanitasi untuk antarmuka Glibc

### 5.5 Glibc-2.44
- **Target Directory:** `$LFS/usr`
- **Cross Compiler Used:** `$LFS_TGT-gcc`
- **Symlink Fix:** Pengaturan direktori dasar FHS di `$LFS/usr`
- **Primary Artifacts:** Pustaka C standar sistem (libc, libm, libpthread)

### 5.6 Libstdc++ dari GCC-16.2.0
- **Target Directory:** `$LFS/usr`
- **Build Directory:** `$LFS/sources/gcc-16.2.0/build`
- **Cleanup Status:** Menghapus berkas pustaka `libstdc++.la`, `libstdc++fs.la`, dan `libsupc++.la`
- **Primary Artifacts:** Pustaka standar C++ untuk lingkungan temporary tools

> **Status:** Bab 5 (Compiling a Cross-Toolchain) selesai sepenuhnya.

---

## Bab 6 - Cross Compiling Temporary Tools

*Catatan: Seluruh kompilasi di bawah ini menggunakan Target Directory di `$LFS/usr`.*

- **6.2 M4-1.4.21:** Pembuatan `$LFS/usr/share/config.site` untuk variabel `posix_spawn`. Exec option: `--host=$LFS_TGT --build=$(build-aux/config.guess)`.
- **6.3 Ncurses-6.6:** Program `tic` sementara dipasang ke `$LFS/tools/bin`. Symlink `libncurses.so` -> `libncursesw.so` & patch macro `curses.h`.
- **6.4 Bash-5.3:** Konfigurasi `--without-bash-malloc`. Symlink `$LFS/bin/sh` -> `bash`.
- **6.5 Coreutils-9.11:** Konfigurasi `--enable-install-program=hostname`. Biner `chroot` dipindah ke `/usr/sbin`.
- **6.6 Diffutils-3.12:** Override `gl_cv_func_strcasecmp_works=yes` untuk bypass check run-time.
- **6.7 File-5.48:** Program `file` versi host dikompilasi di folder `build` untuk signature. Menghapus `libmagic.la`.
- **6.8 Findutils-4.11.0:** Konfigurasi `--localstatedir=/var/lib/locate`.
- **6.9 Gawk-5.4.1:** Penyesuaian `sed` pada `Makefile.in` untuk menghapus direktori `extras`.
- **6.10 Grep-3.12:** Cross-compilation standar (`--host=$LFS_TGT`).
- **6.11 Gzip-1.14:** Cross-compilation standar (`--host=$LFS_TGT`).
- **6.12 Make-4.4.1:** Cross-compilation standar (`--host=$LFS_TGT`).
- **6.13 Patch-2.8:** Cross-compilation standar (`--host=$LFS_TGT`).
- **6.14 Sed-4.10:** Cross-compilation standar (`--host=$LFS_TGT`).
- **6.15 Tar-1.35:** Cross-compilation standar (`--host=$LFS_TGT`).
- **6.16 Xz-5.8.3:** Konfigurasi `--disable-static` & `--docdir=/usr/share/doc/xz-5.8.3`. Menghapus `liblzma.la`.
- **6.17 Binutils-2.47 (Pass 2):** Patch `ltmain.sh`. Menghapus pustaka statis dan libtool archive (`lib{bfd,ctf,ctf-nobfd,opcodes,sframe}.{a,la}`).
- **6.18 GCC-16.2.0 (Pass 2):** Re-extract `mpfr`, `gmp`, `mpc`. Konfigurasi `--with-build-sysroot=$LFS` & PIE/SSP aktif. Symlink `$LFS/usr/bin/cc` -> `gcc`.

> **Status:** Bab 6 (Cross Compiling Temporary Tools) selesai sepenuhnya.

---

## Bab 7 - Entering Chroot and Building Additional Temporary Tools

### 7.2 Changing Ownership
- **Target Directory:** `$LFS`
- **Execution Environment:** Host OS (`root`)
- **Ownership Command:** `chown --from lfs -R root:root $LFS/{usr,var,etc,tools}`
- **Architecture Rule:** Tidak membuat/mengubah direktori `lib64` untuk menjaga konsistensi 64-bit murni.

### 7.3 Preparing Virtual Kernel File Systems
- **Target Mount Points:** `$LFS/{dev,proc,sys,run}`
- **Host Device Binding:** `mount -v --bind /dev $LFS/dev`
- **Virtual Filesystems:** `devpts` (`gid=5,mode=0620`), `proc`, `sysfs`, dan `tmpfs` (`/run`).
- **Shared Memory Setup:** Memasang `tmpfs` pada `$LFS/dev/shm` atau memberi direktori izin `1777`.

### 7.4 Entering the Chroot Environment
- **Execution Command:** `chroot "$LFS" /usr/bin/env -i ... /bin/bash --login`
- **Environment Isolation:** Membersihkan variabel lingkungan host (`-i`).
- **Initial Prompt:** `(lfs chroot) I have no name!:/#` (sebelum pembentukan `/etc/passwd`).

### 7.5 Creating Directories
- **Directory Tree:** Membuat struktur FHS standar (`/{boot,home,mnt,srv}`, dll).
- **Symbolic Links:** `/run` -> `/var/run` dan `/run/lock` -> `/var/lock`.
- **Special Permissions:** `0750` untuk `/root` dan sticky bit `1777` untuk `/tmp` & `/var/tmp`.
- **Warning Rule:** Dilarang keras membuat direktori `/usr/lib64`.

### 7.6 Creating Essential Files & Symlinks
- **Essential Files:** `/etc/mtab` (symlink), `/etc/hosts`, `/etc/passwd`, `/etc/group`.
- **Testing Account:** Akun `tester` (`UID:101, GID:101`).
- **Log Files Setup:** Inisialisasi `/var/log/{btmp,lastlog,faillog,wtmp}` (grup `utmp`).

### 7.7 - 7.20 Instalasi Paket Tambahan Chroot
*(Semua paket dipasang di Target Directory: `/usr`)*
- **7.7 Gettext-1.0:** Menyediakan utilitas internasionalisasi (`--disable-shared`).
- **7.8 Bison-3.8.2:** Generator parser LALR(1).
- **7.9 Perl-5.44.0:** Bahasa skrip esensial.
- **7.10 Zlib-1.3.2:** Pustaka kompresi dasar.
- **7.11 mpdecimal-4.0.1:** Pustaka aritmatika desimal (dibutuhkan Python).
- **7.12 Python-3.14.7:** Interpreter Python dasar.
- **7.13 Texinfo-7.3:** Sistem dokumentasi info GNU.
- **7.14 Util-linux-2.42.2:** Kumpulan utilitas dasar sistem Linux.
- **7.15 Man-pages-6.18:** Halaman manual standar.
- **7.16 Iana-Etc-20260805:** Data referensi IANA (diinstal di `/etc`).
- **7.17 Glibc-2.44:** Pustaka C standar utama untuk seluruh aplikasi sistem.
- **7.18 Bzip2-1.0.8:** Pustaka kompresi blok.
- **7.19 Xz-5.8.3:** Pustaka kompresi LZMA/XZ.
- **7.20 Lz4-1.10.0:** Kompresi data berkecepatan tinggi.

### 7.21 Cleaning up and Saving the Temporary System
- **Documentation Cleanup:** `rm -rf /usr/share/{info,man,doc}/*`
- **Libtool Cleanup:** `find /usr/{lib,libexec} -name \*.la -delete`
- **Tools Removal:** `rm -rf /tools`
- **Chroot Exit & Unmount:** Exit chroot dan melepaskan virtual filesystems.
- **Backup Archive:** Membuat arsip `lfs-temp-tools-13.1-systemd.tar.xz`.

> **Status:** Bab 7 (Entering Chroot) selesai sepenuhnya.

---

## Bab 8 - Installing Basic System Software

- **Sistem Target:** Linux From Scratch 13.1 (x86_64)
- **Lingkungan Build:** Chroot Environment (`/mnt/lfs`)
- **Metode Eksekusi:** Skrip Otomasi Bash Sekuensial
- **Strategi Optimasi:** Kompilasi Paralel (`make -j$(nproc)`), Pengabaian Test Suite (`make check`), dan Pembersihan Manual Direktori Sumber (`/sources`).

### 8.1 Ringkasan Eksekusi & Konfigurasi Utama
- **Keamanan Toolchain:** GCC 16.2.0 dibangun menggunakan *Address Space Layout Randomization* (`--enable-default-pie`) dan *Stack Smashing Protection* (`--enable-default-ssp`).
- **Sistem Bootloader Ganda:** GRUB 2.14 dikompilasi ganda untuk **BIOS (i386-pc)** dan **64-bit UEFI (x86_64-efi)**.
- **Init System & Logging:** Systemd 261.2 dikonfigurasi dengan penyiapan `systemd-machine-id-setup` serta `systemctl preset-all`.
- **Kepatuhan FHS:** Penyesuaian lokasi biner, seperti memindahkan `chroot` ke `/usr/sbin` (Coreutils).

### 8.2 Daftar Paket Utama yang Terpasang

| Nama Paket | Versi | Status | Catatan Ringkas Konfigurasi |
| :--- | :--- | :--- | :--- |
| **Glibc** | 2.44 | Selesai | Patch FHS & upstream fixes, bypass `test-installation.pl`, locale dasar. |
| **Libelf** | 0.195 | Selesai | Pustaka ELF terpasang (`libelf.so`), pustaka statis dihapus. |
| **Kmod** | 34.2 | Selesai | Build via Meson/Ninja, *symlink* modul kernel terpasang. |
| **Coreutils** | 9.11 | Selesai | Patch i18n, `FORCE_UNSAFE_CONFIGURE=1`, penyesuaian FHS. |
| **MPFR** | 4.2.2 | Selesai | Opsi `--enable-thread-safe` aktif, dokumentasi HTML terpasang. |
| **GCC** | 16.2.0 | Selesai | Dukungan C/C++, PIE & SSP aktif. |
| **Bash** | 5.3 | Selesai | Menggunakan Readline sistem, `--without-bash-malloc`. |
| **DejaGNU** | 1.6.3 | Selesai | Terpasang beserta dokumentasi HTML dan plaintext. |
| **OpenSSL** | 4.0.1 | Selesai | Pustaka kriptografi utama sistem. |
| **GDBM / Gperf / Expat**| - | Selesai | Seluruh pustaka pendukung terverifikasi dan siap digunakan. |
| **Inetutils** | 2.8 | Selesai | Perkakas jaringan dasar (`ping`, `hostname`, dll) terpasang. |
| **Less** | 704 | Selesai | *Pager* terminal terpasang. |
| **GRUB** | 2.14 | Selesai | Kompilasi ganda untuk modul BIOS dan 64-bit UEFI. |
| **Tar** | 1.35 | Selesai | Patch `acl_fix-1`, `FORCE_UNSAFE_CONFIGURE=1`. |
| **Texinfo** | 7.3 | Selesai | Perkakas dokumentasi info & komponen TeX terpasang. |
| **Vim** | 9.2.1025 | Selesai | Konfigurasi `/etc/vimrc` siap pakai. |
| **Systemd** | 261.2 | Selesai | Aturan udev disesuaikan, `machine-id` tergenerasi. |
| **E2fsprogs** | 1.47.4 | Selesai | Pustaka statis dibersihkan, pembaruan indeks `install-info`. |
| **Jinja2** | 3.1.6 | Selesai | *Wheel* Python terpasang di `/usr/lib/python3.14/site-packages`. |

### 8.3 Hasil Sanity Check Toolchain (GCC & Dynamic Linker)
Sistem LFS dinyatakan dalam kondisi **sehat (healthy)**:
1. **Dynamic Linker Interpreter:** Tepat mengarah ke `/usr/lib/ld-linux-x86-64.so.2`.
2. **Startfile Checking:** Ditemukan `/usr/lib/Scrt1.o`, `crti.o`, dan `crtn.o`.
3. **Header Search Path:** Terbaca tepat dari `/usr/include`.
4. **Linker Search Path:** Mencakup `/usr/lib` dan `/usr/x86_64-pc-linux-gnu/lib`.
5. **C Library Linking:** Sukses dipetakan ke `/usr/lib/libc.so.6`.

### 8.84 Stripping (Pembersihan Simbol Debug)
- **Tujuan Utama:** Menghapus simbol debug dan tabel simbol yang tidak diperlukan pada seluruh biner dan pustaka sistem.
- **Hasil Penghematan:** Memangkas ukuran sistem hingga **~2 GB** (krusial untuk optimasi ukuran SquashFS/Live ISO).
- **Mekanisme Keamanan:** Biner aktif (`bash`, `strip`, `libc.so.6`) dikopi ke `/tmp` terlebih dahulu sebelum di-*strip* untuk mencegah *crash*.
- **Pengawetan Simbol:** Simbol debug kritis (Glibc & GCC) dikompresi (Zstd) menjadi `.dbg` terpisah untuk keperluan *regression test* di BLFS.

### 8.85 Cleaning Up
Langkah pembersihan akhir lingkungan chroot:
- **Membersihkan sisa berkas pengujian di `/tmp`:**
  ```bash
  rm -rf /tmp/{*,.*}
  ```
- **Menghapus Libtool Archive (`.la`) yang memicu error di BLFS:**
  ```bash
  find /usr/lib /usr/libexec -name \*.la -delete
  ```
- **Menghapus sisa kompilator sementara dari Bab 6 & 7:**
  ```bash
  find /usr -depth -name $(uname -m)-lfs-linux-gnu\* | xargs rm -rf
  ```
- **Menghapus akun *tester* sementara:**
  ```bash
  userdel -r tester
  ```

---

## Bab 9 - System Configuration

### 9.1 Overview Bab 9
Fokus bab ini adalah konfigurasi operasional dasar sistem LFS: Pengaturan jaringan, *Udev*, jam sistem, tata letak *keyboard*, *locale*, dan penyesuaian layanan Systemd.

### 9.2 Penanganan Perangkat dan Modul (Udev)
- **Konsep Dasar:** `systemd-udevd` memanfaatkan `devtmpfs` (RAM) dan `sysfs` untuk membuat *device node* dinamis di `/dev`.
- **Evolusi Sistem:** Menggantikan metode *static* (`MAKEDEV`/`mknod`) dan `devfs` lama.

### 9.3 Manajemen Perangkat Duplikat
- **Masalah:** Penamaan *node* perangkat sejenis (seperti webcam) dapat tertukar saat *reboot*.
- **Solusi:** Pembuatan aturan di `/etc/udev/rules.d/83-duplicate_devs.rules` untuk *persistent symlink* berdasarkan *idVendor*/*idProduct*.

### 9.4 Konfigurasi Jam Sistem & Zona Waktu
- **Hardware Clock:** Dikonfigurasi ke `UTC` pada `/etc/adjtime`.
- **Zona Waktu (`/etc/localtime`):** Dihubungkan ke `/usr/share/zoneinfo/Asia/Jakarta`.
- **NTP Sync (`timesyncd.conf`):** Dikonfigurasi ke server NTP Indonesia (`*.id.pool.ntp.org`).

### 9.5 Konfigurasi Konsol Linux
- **Keyboard Layout:** Standar US QWERTY (`KEYMAP=us`).
- **Console Font:** Menggunakan `Lat2-Terminus16` untuk dukungan *glyph* karakter Unicode yang sempurna pada konsol TTY.

### 9.6 Konfigurasi System Locale & Profile Shell
- **Default Locale:** `/etc/locale.conf` ditetapkan ke `en_US.UTF-8`.
- **Global Shell (`/etc/profile`):** Memiliki *fallback* TTY otomatis ke `LANG=C.UTF-8` jika terminal yang digunakan tidak mendukung font *locale* utama.

### 9.7 Konfigurasi Readline (`/etc/inputrc`)
- **Fitur Utama:** Mendukung input/output 8-bit (UTF-8), mematikan *terminal bell*, dan memetakan tombol navigasi standar (Home, End, PageUp, dll) secara konsisten di seluruh TTY/emulator.

### 9.8 Konfigurasi Shell Valid (`/etc/shells`)
Menyediakan daftar *login shell* resmi (`/bin/sh`, `/bin/bash`) untuk keperluan keamanan otentikasi login (GDM, daemon FTP) dan perintah `chsh`.

### 9.9 Konfigurasi Perilaku Systemd
- **Pencegahan Clearscreen Boot:** Menambahkan `TTYVTDisallocate=no` pada `getty@tty1.service` agar log *booting* tetap terbaca.
- **Manajemen Core Dump:** Membatasi penggunaan ruang hingga maksimal 5 GB.
- **Dukungan Proses Latar:** `KillUserProcesses=no` pada `systemd-logind` agar aplikasi seperti `screen`/`tmux` tidak mati saat pengguna *logout*.

> **Status:** Bab 9 (System Configuration) selesai 100%.

---

## Bab 10 - Making the LFS System Bootable

### 10.1 Overview Bab 10
Pembuatan tabel *mounting* (`/etc/fstab`), kompilasi Kernel Linux, serta instalasi *bootloader* GRUB agar OS dapat berjalan independen.

### 10.2 Konfigurasi File System Table (`/etc/fstab`)
- **Root (`/`):** ext4, urutan *fsck* `1 1`.
- **Swap:** Prioritas `pri=1`.
- **UEFI ESP (`/boot/efi`):** Memakai format vfat dengan `codepage=437,iocharset=iso8859-1`.

### 10.3 Kompilasi dan Instalasi Kernel Linux
- **Paket Target:** Linux Kernel 7.1.8.
- **Metode:** `make defconfig` disesuaikan untuk Systemd (PSI, MEMCG), NVMe, UEFI Runtime/Stub, VFAT NLS, dan *SimpleDRM console*.
- **Biner Terinstal:** `/boot/vmlinuz-7.1.8-lfs-13.1-systemd`, `System.map`, dan `config-7.1.8`.

### 10.4 Instalasi dan Konfigurasi Bootloader GRUB
- **Mode Booting:** Disiapkan untuk **BIOS Legacy** (*stub loader* di MBR) dan **UEFI** (`BOOTX64.EFI` terpasang *removable*).
- **Konfigurasi Boot Menu (`/boot/grub/grub.cfg`):** Mendukung resolusi *framebuffer* 1024x768 dan *pointing* otomatis ke kernel utama LFS.

> **Status:** Bab 10 (Bootable System) selesai 100%.

---

## Bab 11 - The End

### 11.1 Identitas & Branding Distro
- **OS Name:** `WebForge OS` | **Codename:** `wefor` | **Release Version:** `13.1-systemd`
- **Metadata Files:** Dikonfigurasi di `/etc/lfs-release`, `/etc/lsb-release`, dan `/etc/os-release`.

### 11.2 Prosedur Reboot dan Validasi Akhir
- **Checklist:** Verifikasi akhir untuk `/etc/fstab`, `hosts`, `profile`, `resolv.conf`, dll.
- **Prosedur Exit & Unmount:**
  1. Keluar dari *chroot* (`exit`).
  2. Melepas *virtual filesystem* secara berurutan: `/dev/pts` -> `/dev/shm` -> `/dev` -> `/run` -> `/proc` -> `/sys`.
  3. Melepas partisi tambahan sebelum partisi LFS utama.
- **Kesiapan Booting:** Sistem siap di-*reboot*.

### 11.3 Aktivitas Pasca-LFS & Manajemen BLFS
- **Penentuan Arah:** Pemilihan *path* pengembangan menuju status *Server* (Daemon) atau *Workstation* (GUI).
- **Metode Pengembangan Lanjutan (BLFS):**
  - **Chroot dari Host:** Bekerja sambil memanfaatkan *browser* dan OS host.
  - **Remote SSH:** Instalasi `sshd` untuk akses pengembangan *remote*.
  - **Direct Console (TTY):** Menggunakan utilitas CLI murni (seperti `gpm` dan `links`) di dalam OS LFS itu sendiri.