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


## Dokumentasi Bab 5.2 - Binutils-2.47 (Pass 1)
- Storage Directory: `$LFS/sources`
- Build Directory: `$LFS/sources/binutils-2.47/build`
- Target Directory: `$LFS/tools`
- Target Architecture: `$LFS_TGT`
- Primary Artifacts: Cross-linker (`ld`) dan cross-assembler (`as`) awal

## Dokumentasi Bab 5.3 - GCC-16.2.0 (Pass 1)
- Embedded Packages: `mpfr-4.2.2`, `gmp-6.3.0`, `mpc-1.4.1`
- Target Directory: `$LFS/tools`
- Architecture Fix: Sed patch pada `gcc/config/i386/t-linux64` untuk mengubah `lib64` ke `lib`
- Primary Artifacts: Cross-compiler C (`$LFS_TGT-gcc`) dan `libgcc` awal

## Dokumentasi Bab 5.4 - Linux API Headers
- Source Directory: `$LFS/sources/linux-6.x`
- Target Directory: `$LFS/usr/include`
- Pre-clean: `make mrproper`
- Primary Artifacts: Header kernel ter-sanitasi untuk antarmuka Glibc

## Dokumentasi Bab 5.5 - Glibc-2.44
- Target Directory: `$LFS/usr`
- Cross Compiler Used: `$LFS_TGT-gcc`
- Symlink Fix: Pengaturan direktori dasar FHS di `$LFS/usr`
- Primary Artifacts: Pustaka C standar sistem (libc, libm, libpthread)

## Dokumentasi Bab 5.6 - Libstdc++ from GCC-16.2.0
- Target Directory: `$LFS/usr`
- Build Directory: `$LFS/sources/gcc-16.2.0/build`
- Cleanup Status: Menghapus berkas pustaka `libstdc++.la`, `libstdc++fs.la`, dan `libsupc++.la`
- Primary Artifacts: Pustaka standar C++ untuk lingkungan temporary tools

*Bab 5 (Compiling a Cross-Toolchain) Selesai sepenuhnya.*

## Dokumentasi Bab 6.2 - M4-1.4.21
- Target Directory: `$LFS/usr`
- Environment Config: Pembuatan `$LFS/usr/share/config.site` untuk variabel `posix_spawn` glibc-2.44
- Execution Option: `--host=$LFS_TGT --build=$(build-aux/config.guess)`

## Dokumentasi Bab 6.3 - Ncurses-6.6
- Target Directory: `$LFS/usr`
- Host Tool Built: Program `tic` sementara dikompilasi di folder `build` dan dipasang ke `$LFS/tools/bin`
- Compatibility Fixes: Symlink `libncurses.so` -> `libncursesw.so` dan patch macro `curses.h`

## Dokumentasi Bab 6.4 - Bash-5.3
- Target Directory: `$LFS/usr`
- Configuration Option: `--without-bash-malloc` (menghindari segfault dengan memakai Glibc malloc)
- Shell Link: Symlink `$LFS/bin/sh` -> `bash`

## Dokumentasi Bab 6.5 - Coreutils-9.11
- Target Directory: `$LFS/usr`
- Configuration Option: `--enable-install-program=hostname`
- Path Adjustments: Memindahkan biner `chroot` ke `/usr/sbin` dan manpage `chroot.1` ke section 8

## Dokumentasi Bab 6.6 - Diffutils-3.12
- Target Directory: `$LFS/usr`
- Cross Fix: Override `gl_cv_func_strcasecmp_works=yes` untuk melewati pengecekan run-time cross-compilation

## Dokumentasi Bab 6.7 - File-5.48
- Target Directory: `$LFS/usr`
- Temporary Tool Built: Program `file` versi host dikompilasi di folder `build` untuk pembuatan berkas signature
- Cleanup Status: Menghapus `$LFS/usr/lib/libmagic.la`

## Dokumentasi Bab 6.8 - Findutils-4.11.0
- Target Directory: `$LFS/usr`
- Configuration Option: `--localstatedir=/var/lib/locate`

## Dokumentasi Bab 6.9 - Gawk-5.4.1
- Target Directory: `$LFS/usr`
- Source Fix: Penyesuaian `sed` pada `Makefile.in` untuk menghapus direktori `extras`

## Dokumentasi Bab 6.10 - Grep-3.12
- Target Directory: `$LFS/usr`
- Build Options: Cross-compilation standar menggunakan `--host=$LFS_TGT`

## Dokumentasi Bab 6.11 - Gzip-1.14
- Target Directory: `$LFS/usr`
- Build Options: Cross-compilation standar menggunakan `--host=$LFS_TGT`

## Dokumentasi Bab 6.12 - Make-4.4.1
- Target Directory: `$LFS/usr`
- Build Options: Cross-compilation standar menggunakan `--host=$LFS_TGT`

## Dokumentasi Bab 6.13 - Patch-2.8
- Target Directory: `$LFS/usr`
- Build Options: Cross-compilation standar menggunakan `--host=$LFS_TGT`

## Dokumentasi Bab 6.14 - Sed-4.10
- Target Directory: `$LFS/usr`
- Build Options: Cross-compilation standar menggunakan `--host=$LFS_TGT`

## Dokumentasi Bab 6.15 - Tar-1.35
- Target Directory: `$LFS/usr`
- Build Options: Cross-compilation standar menggunakan `--host=$LFS_TGT`

## Dokumentasi Bab 6.16 - Xz-5.8.3
- Target Directory: `$LFS/usr`
- Configuration Options: `--disable-static` dan `--docdir=/usr/share/doc/xz-5.8.3`
- Cleanup Status: Menghapus `$LFS/usr/lib/liblzma.la`

## Dokumentasi Bab 6.17 - Binutils-2.47 (Pass 2)
- Target Directory: `$LFS/usr`
- Source Patch: Modified `ltmain.sh` baris 6031 untuk mencegah kontaminasi pustaka host
- Build Options: `--enable-shared`, `--enable-64-bit-bfd`, `--enable-new-dtags`, `--enable-default-hash-style=gnu`
- Cleanup Status: Menghapus pustaka statis dan libtool archive (`lib{bfd,ctf,ctf-nobfd,opcodes,sframe}.{a,la}`)

## Dokumentasi Bab 6.18 - GCC-16.2.0 (Pass 2)
- Embedded Packages: Re-extracted `mpfr`, `gmp`, dan `mpc` ke dalam pohon sumber GCC
- Target Directory: `$LFS/usr`
- Configuration Options: `--with-build-sysroot=$LFS`, `--enable-default-pie`, `--enable-default-ssp`, `--enable-languages=c,c++`
- Environment Overrides: `CXX_FOR_TARGET="$LFS_TGT-gcc -nostdinc++"`, `LDFLAGS_FOR_TARGET=-L$PWD/$LFS_TGT/libgcc`
- Utility Link: Symlink `$LFS/usr/bin/cc` -> `gcc`

*Bab 6 (Cross Compiling Temporary Tools) Selesai sepenuhnya.*

## Dokumentasi Bab 7.2 - Changing Ownership
- Target Directory: `$LFS`
- Execution Environment: Host OS (`root`)
- Ownership Command: `chown --from lfs -R root:root $LFS/{usr,var,etc,tools}`
- Architecture Rule: Tidak membuat atau mengubah direktori `lib64` untuk menjaga konsistensi arsitektur 64-bit murni

## Dokumentasi Bab 7.3 - Preparing Virtual Kernel File Systems
- Target Mount Points: `$LFS/{dev,proc,sys,run}`
- Host Device Binding: `mount -v --bind /dev $LFS/dev`
- Virtual Filesystems: `devpts` (`gid=5,mode=0620`), `proc`, `sysfs`, dan `tmpfs` (`/run`)
- Shared Memory Setup: Memasang `tmpfs` pada `$LFS/dev/shm` (`nosuid,nodev`) atau direktori berizin `1777`

## Dokumentasi Bab 7.4 - Entering the Chroot Environment
- Execution Command: `chroot "$LFS" /usr/bin/env -i HOME=/root TERM="$TERM" PS1='(lfs chroot) \u:\w\$ ' PATH=/usr/bin:/usr/sbin MAKEFLAGS="-j$(nproc)" TESTSUITEFLAGS="-j$(nproc)" /bin/bash --login`
- Environment Isolation: Membersihkan seluruh variabel lingkungan host (`-i`) dan membatasi akses pada direktori `$LFS`
- Initial Prompt: `(lfs chroot) I have no name!:/#` (sebelum pembentukan `/etc/passwd`)

## Dokumentasi Bab 7.5 - Creating Directories
- Target Directory: Root chroot (`/`)
- Directory Tree: Membuat struktur FHS standar (`/{boot,home,mnt,opt,srv}`, `/etc/{opt,sysconfig}`, `/usr/{,local/}{include,src}`, `/var/{cache,local,log,mail,opt,spool}`, dll.)
- Symbolic Links: `ln -sfv /run /var/run` dan `ln -sfv /run/lock /var/lock`
- Special Permissions: Permisi `0750` untuk `/root` dan sticky bit `1777` untuk `/tmp` serta `/var/tmp`
- Warning Rule: Dilarang keras membuat direktori `/usr/lib64`

## Dokumentasi Bab 7.6 - Creating Essential Files & Symlinks
- Mount Link: Symlink `/proc/self/mounts` ke `/etc/mtab`
- Essential Files: Membuat `/etc/hosts`, `/etc/passwd`, dan `/etc/group` dasar
- Testing Account: Menambahkan akun `tester` (`UID:101, GID:101`) beserta direktori `/home/tester`
- Shell Refresh: Eksekusi `exec /usr/bin/bash --login` untuk memperbarui resolusi user prompt menjadi `root`
- Log Files Setup: Inisialisasi `/var/log/{btmp,lastlog,faillog,wtmp}` dengan kepemilikan grup `utmp`

## Dokumentasi Bab 7.7 - Gettext-1.0
- Target Directory: `/usr`
- Script Name: `01-Gettext_1_0.sh`
- Configuration Options: `--disable-shared`
- Purpose: Menyediakan utilitas internasionalisasi dan penerjemahan pesan awal di lingkungan chroot

## Dokumentasi Bab 7.8 - Bison-3.8.2
- Target Directory: `/usr`
- Script Name: `02-Bison_3_8_2.sh`
- Configuration Options: `--docdir=/usr/share/doc/bison-3.8.2`
- Purpose: Menyediakan generator parser LALR(1) untuk paket-paket berikutnya

## Dokumentasi Bab 7.9 - Perl-5.44.0
- Target Directory: `/usr`
- Script Name: `03-Perl_5_44_0.sh`
- Configuration Options: `-des -Dprefix=/usr -Dvendorprefix=/usr -Duseshrplib`
- Purpose: Bahasa pemrograman skrip esensial untuk pembangunan paket dan test suite

## Dokumentasi Bab 7.10 - Zlib-1.3.2
- Target Directory: `/usr`
- Script Name: `04-Zlib_1_3_2.sh`
- Build Artifacts: Pustaka statis (`libz.a`) dan dinamis (`libz.so.1.3.2`)
- Purpose: Menyediakan pustaka kompresi dan dekompresi data dasar

## Dokumentasi Bab 7.11 - mpdecimal-4.0.1
- Target Directory: `/usr`
- Script Name: `05-mpdecimal_4_0_1.sh`
- Configuration Options: `--disable-cxx`
- Purpose: Pustaka aritmatika desimal presisi tinggi yang dibutuhkan oleh Python

## Dokumentasi Bab 7.12 - Python-3.14.7
- Target Directory: `/usr`
- Script Name: `06-Python_3_14_7.sh`
- Configuration Options: `--enable-shared --with-system-expat --without-ensurepip`
- Purpose: Interpreter Python dasar untuk utilitas sistem dan proses kompilasi lanjutan

## Dokumentasi Bab 7.13 - Texinfo-7.3
- Target Directory: `/usr`
- Script Name: `07-Texinfo_7_3.sh`
- Verification Command: `makeinfo --version`
- Purpose: Sistem pembuatan dan pembaca dokumentasi info GNU

## Dokumentasi Bab 7.14 - Util-linux-2.42.2
- Target Directory: `/usr`
- Script Name: `08-Util_linux_2_42_2.sh`
- Configuration Options: `--disable-chfn-chsh --disable-login --disable-nologin --disable-su --disable-setpriv --disable-runuser --disable-pylibmount --without-python`
- Purpose: Kumpulan utilitas dasar sistem Linux (mount, fdisk, fsck, dll.)

## Dokumentasi Bab 7.15 - Man-pages-6.18
- Target Directory: `/usr`
- Script Name: `09-Man_pages_6_18.sh`
- Installation Method: `make prefix=/usr install`
- Purpose: Dokumentasi halaman manual (man pages) standar untuk sistem Linux

## Dokumentasi Bab 7.16 - Iana-Etc-20260805
- Target Directory: `/etc`
- Script Name: `10-Iana_Etc_20260805.sh`
- Target Files: `/etc/protocols` dan `/etc/services`
- Purpose: Menyediakan data referensi layanan jaringan dan protokol IANA

## Dokumentasi Bab 7.17 - Glibc-2.44
- Target Directory: `/usr`
- Script Name: `11-Glibc_2_44.sh`
- Configuration Options: `--host=$LFS_TGT --build=$(../scripts/config.guess) --enable-kernel=4.19 --with-headers=/usr/include`
- Purpose: Pustaka C standar utama untuk seluruh aplikasi sistem LFS

## Dokumentasi Bab 7.18 - Bzip2-1.0.8
- Target Directory: `/usr`
- Script Name: `13-Bzip2_1_0_8.sh`
- Build Options: Menggunakan `Makefile-libbz2_so` untuk pembuatan shared library
- Purpose: Pustaka dan utilitas kompresi blok bzip2

## Dokumentasi Bab 7.19 - Xz-5.8.3
- Target Directory: `/usr`
- Script Name: `14-Xz_5_8_3.sh`
- Configuration Options: `--disable-static --docdir=/usr/share/doc/xz-5.8.3`
- Purpose: Pustaka kompresi LZMA/XZ untuk mendukung paket berarsip `.tar.xz`

## Dokumentasi Bab 7.20 - Lz4-1.10.0
- Target Directory: `/usr`
- Script Name: `15-Lz4_1_10_0.sh`
- Build Options: `BUILD_STATIC=no PREFIX=/usr`
- Purpose: Kompresi data berkecepatan tinggi yang dibutuhkan oleh perkakas sistem modern

## Dokumentasi Bab 7.21 - Cleaning up and Saving the Temporary System
- Documentation Cleanup: Menghapus dokumentasi sementara via `rm -rf /usr/share/{info,man,doc}/*`
- Libtool Cleanup: Menghapus berkas `.la` via `find /usr/{lib,libexec} -name \*.la -delete`
- Tools Removal: Menghapus direktori temporary tools `/tools` (`rm -rf /tools`)
- Chroot Exit & Unmount: Exit chroot dan melepaskan virtual filesystems di Host OS (`umount $LFS/dev/pts`, dll.)
- Backup Archive: Membuat arsip cadangan `lfs-temp-tools-13.1-systemd.tar.xz` di direktori home root host

*Bab 7 (Entering Chroot and Building Additional Temporary Tools) Selesai sepenuhnya.*