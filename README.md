# WebForge OS

### Pengembangan Distro Linux Berbasis Linux From Scratch untuk Web Server Ringan

![Project](https://img.shields.io/badge/Project-WebForge%20OS-blue)
![Platform](https://img.shields.io/badge/Platform-Linux-orange)
![Purpose](https://img.shields.io/badge/Purpose-Lightweight%20Web%20Server-green)

## Tentang WebForge OS

**WebForge OS** merupakan distribusi Linux berbasis Linux From Scratch (LFS) yang dikembangkan untuk kebutuhan web server ringan. Sistem ini dirancang dengan mengutamakan efisiensi penggunaan sumber daya serta kemudahan dalam pengelolaan layanan web server.

WebForge OS menggunakan Nginx sebagai perangkat lunak web server utama dan systemd untuk mengelola proses serta layanan sistem. Selain itu, WebForge OS menyediakan perintah khusus melalui command `webforge` untuk membantu pengguna mengelola website, layanan server, keamanan, monitoring, serta pencadangan konfigurasi.

Proyek ini dikembangkan sebagai bagian dari Final Project Mata Kuliah Sistem Operasi, Program Studi Informatika, Universitas Siliwangi.

## Tujuan Pengembangan

WebForge OS dikembangkan dengan tujuan:

- Menghasilkan distribusi Linux berbasis Linux From Scratch.
- Menyediakan sistem operasi yang difokuskan untuk menjalankan web server.
- Mengintegrasikan Nginx sebagai layanan web server utama.
- Mempermudah pengelolaan layanan server melalui command `webforge`.
- Menyediakan pengelolaan jaringan dan konfigurasi keamanan dasar.
- Mengoptimalkan penggunaan sumber daya sistem untuk kebutuhan web server sederhana.

## Fitur Utama

### 1. Web Server Management
Pengelolaan layanan Nginx, meliputi:
- Menjalankan dan menghentikan layanan.
- Memulai ulang dan memuat ulang konfigurasi.
- Memeriksa status layanan.
- Mengelola konfigurasi website.

### 2. Site Management
Mengelola website melalui command:
- Menambahkan dan menghapus website.
- Mengaktifkan dan menonaktifkan website.
- Mengubah konfigurasi website.
- Mengatur redirect dan reverse proxy.
- Mengaktifkan mode maintenance.

### 3. SSL/TLS Management
Menyediakan perintah untuk:
- Membuat sertifikat SSL.
- Memperbarui sertifikat.
- Memeriksa status sertifikat.
- Mengelola sertifikat SSL/TLS.

### 4. Firewall Management
Menyediakan pengelolaan firewall menggunakan nftables, seperti:
- Memeriksa status firewall.
- Mengizinkan atau menolak koneksi.
- Mengelola daftar alamat IP yang diblokir.
- Mengatur port jaringan.

### 5. Monitoring dan Logging
Menyediakan fitur pemantauan sistem, seperti:
- Memeriksa penggunaan sumber daya.
- Melihat koneksi aktif.
- Memantau penggunaan penyimpanan.
- Melihat access log dan error log.
- Memeriksa kondisi kesehatan sistem.

### 6. Security Management
Mendukung pengelolaan keamanan dasar melalui:
- Audit konfigurasi sistem.
- Pengaturan hak akses berkas.
- Pengelolaan pengguna.
- Pengelolaan SSH.
- Pemeriksaan keamanan header HTTP.

### 7. Backup dan Restore
Menyediakan pengelolaan pencadangan dan pemulihan konfigurasi serta data website.

**Catatan:** Fitur-fitur di atas merupakan fitur yang direncanakan atau disediakan melalui command WebForge. Ketersediaan akhirnya perlu disesuaikan dengan hasil implementasi dan pengujian.

## Teknologi yang Digunakan

| Teknologi | Kegunaan |
|---|---|
| Linux From Scratch (LFS) | Dasar pembangunan distribusi Linux |
| Linux Kernel | Inti sistem operasi |
| Nginx | Web server utama |
| systemd | Pengelolaan proses dan layanan sistem |
| Bash Shell | Menjalankan script dan command |
| nftables | Pengelolaan firewall |
| VirtualBox | Lingkungan virtual untuk pengujian |

## Persyaratan Sistem

WebForge OS dikembangkan untuk dijalankan pada lingkungan virtual maupun perangkat fisik yang mendukung Linux.

Spesifikasi minimum dan rekomendasi akan dicantumkan berdasarkan hasil pengujian ISO.

| Komponen | Spesifikasi |
|---|---|
| Prosesor | Menunggu hasil pengujian |
| RAM | Menunggu hasil pengujian |
| Penyimpanan | Menunggu hasil pengujian |
| Virtualisasi | VirtualBox atau perangkat yang mendukung booting ISO |

## Instalasi

### Persiapan

Sebelum menjalankan WebForge OS, siapkan:

1. File ISO WebForge OS.
2. Oracle VM VirtualBox atau komputer yang mendukung booting ISO.

### Menjalankan melalui VirtualBox

1. Buka Oracle VM VirtualBox.
2. Buat virtual machine baru.
3. Pilih tipe sistem operasi Linux yang sesuai.
4. Atur kapasitas RAM dan penyimpanan.
5. Masukkan file ISO WebForge OS ke virtual optical drive.
6. Jalankan virtual machine.
7. Ikuti proses booting dan instruksi yang ditampilkan.

**Catatan:** Mekanisme instalasi permanen, apabila tersedia, akan dijelaskan setelah proses build ISO dan pengujian selesai.

## Cara Penggunaan

WebForge OS menyediakan command `webforge` sebagai antarmuka pengelolaan layanan server melalui terminal.

### Perintah Dasar

| Command | Fungsi |
|---|---|
| `webforge help` | Menampilkan panduan penggunaan |
| `webforge sysinfo` | Menampilkan informasi sistem |
| `webforge status` | Memeriksa status layanan |
| `webforge health` | Memeriksa kondisi sistem |
| `webforge monitor` | Memantau penggunaan sumber daya |
| `webforge site list` | Menampilkan daftar website |
| `webforge version` | Memeriksa versi Nginx melalui kelompok command Nginx |

### Pengelolaan Nginx

| Command | Fungsi |
|---|---|
| `webforge start` | Menjalankan Nginx |
| `webforge stop` | Menghentikan Nginx |
| `webforge restart` | Memulai ulang Nginx |
| `webforge reload` | Memuat ulang konfigurasi Nginx |
| `webforge test` | Memeriksa konfigurasi Nginx |

### Monitoring Sistem

| Command | Fungsi |
|---|---|
| `webforge stats` | Melihat statistik sistem |
| `webforge conn` | Melihat koneksi aktif |
| `webforge disk` | Memeriksa penggunaan penyimpanan |
| `webforge log access` | Melihat access log |
| `webforge log error` | Melihat error log |

Untuk melihat panduan command lainnya, gunakan:

```bash
webforge help
```

Untuk melihat bantuan berdasarkan kelompok perintah:

```bash
webforge help <command>
```

**Catatan:** Jalankan command tersebut di terminal WebForge OS. Sintaks dan fungsi setiap command harus disesuaikan dengan implementasi aktual.

## Struktur Repository

Repository WebForge OS memiliki beberapa direktori utama:

| Direktori | Keterangan |
|---|---|
| `config/` | Berisi konfigurasi sistem |
| `docs/` | Berisi dokumentasi proyek |
| `scripts/` | Berisi script pembangunan dan instalasi paket |
| `webforge-build/` | Berisi kebutuhan proses pembangunan distro |

Direktori `scripts/` juga dibagi berdasarkan bagian pengerjaan anggota kelompok.

## Pengujian

Pengujian WebForge OS dilakukan untuk mengetahui keberhasilan implementasi sistem dan kesesuaiannya dengan tujuan pengembangan.

Aspek pengujian meliputi:

- Keberhasilan proses booting sistem.
- Fungsi layanan Nginx.
- Akses website melalui browser.
- Fungsi command WebForge.
- Penggunaan CPU dan RAM.
- Penggunaan penyimpanan.
- Fungsi konfigurasi jaringan dan keamanan dasar.

Hasil pengujian dan perbandingan performa akan ditambahkan setelah pengujian ISO selesai dilaksanakan.

## Anggota Kelompok

Proyek ini dikembangkan oleh Kelompok 3 Mata Kuliah Sistem Operasi.

| No. | Nama | NPM |
|---|---|---|
| 1 | Ghantia Citra Karini | 257006111068 |
| 2 | Indah Kasih Lestari | 257006111106 |
| 3 | Diwanti Najma Tsaqib | 257006111107 |
| 4 | Fauzi Firmansyah | 257006111109 |
| 5 | Nazwa Khoerunnisa Hendriansyah | 257006111110 |
| 6 | Alia Zirlyanti Aripin | 257006111111 |

## Informasi Proyek

**Mata Kuliah:** Sistem Operasi  
**Program Studi:** Informatika  
**Fakultas:** Teknik  
**Universitas:** Universitas Siliwangi  
**Tahun Akademik:** Ganjil 2026/2027  
**Dosen Pengampu:** Muhammad Sidik Asyaky, S.T., M.T.

## Repository

Source code dan dokumentasi proyek dapat diakses melalui:

https://github.com/fuzi11/sistem-operasii

## Lisensi

Proyek ini menggunakan lisensi yang tercantum dalam file `LICENSE` pada repository.
