# WebForge OS - Build Log & ISO Specification

## 1. Spesifikasi Umum
- **Base System:** Linux From Scratch (LFS) custom bootstrap.
- **Package Manager:** APK (Alpine Package Keeper) untuk kemudahan instalasi paket tanpa kompilasi manual.
- **Target ISO Type:** Hybrid Live & Installer ISO (Bootable via BIOS & UEFI).

## 2. Struktur Menu Boot (ISO Startup)
Saat ISO dinyalakan, pengguna akan disambut oleh *bootloader menu* dengan pilihan:
- Live Environment (Uji coba sistem tanpa instalasi)
- CLI Installer (Instalasi berbasis baris perintah cepat)
- TUI Installer (Pemasang interaktif layar biru / Dialog-based setup)

## 3. Alur Kerja TUI Installer (Layar Biru)
1. **Welcome Screen:** Sapaan pembuka dan informasi sistem.
2. **Locale & Keyboard:** Konfigurasi zona waktu dan tata letak keyboard.
3. **Partitioning:** Pemilihan disk dan pembuatan partisi (Root, Swap, dll).
4. **User Setup:** Input nama pengguna, password user, dan password root.
5. **Base Installation:** Ekstraksi direktori sistem dasar (*SquashFS*) ke disk target.
6. **Bootloader Setup:** Instalasi GRUB ke disk utama.
7. **Finishing:** Pesan sukses dan opsi *reboot*.


## 4. Tahap Pembuatan ISO
- **Rootfs Synchronization:** Direktori LFS berhasil disalin dari `/mnt/lfs` ke `rootfs`.
- **SquashFS Compression:** Berkas sistem dikompresi menggunakan XZ.
- **Kernel & Initramfs:** Berkas kernel dan initramfs disalin ke direktori `isodir/boot/`.
- **Bootloader Configuration:** Berkas `grub.cfg` berhasil dikonfigurasi untuk menu *booting*.

