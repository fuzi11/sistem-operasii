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