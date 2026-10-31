#!/usr/bin/env bash

show_help() {
  local topic="$1"

  if [ "$topic" == "doctor" ]; then
    echo "=== WEBFORGE DOCTOR (DIAGNOSIS SISTEM) ==="
    local issues=0

    if systemctl is-active --quiet nginx; then
      echo "[✔] Nginx berjalan normal."
    else
      echo "[✘] PERINGATAN: Nginx tidak aktif!"
      issues=$((issues + 1))
    fi

    if nginx -t > /dev/null 2>&1; then
      echo "[✔] Sintaks konfigurasi Nginx valid."
    else
      echo "[✘] PERINGATAN: Terdapat error pada sintaks konfigurasi Nginx!"
      issues=$((issues + 1))
    fi

    if systemctl is-active --quiet nftables; then
      echo "[✔] Firewall (nftables) aktif."
    else
      echo "[✘] PERINGATAN: Firewall nftables mati!"
      issues=$((issues + 1))
    fi

    local disk_usage
    disk_usage=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
    if [ "$disk_usage" -gt 90 ]; then
      echo "[✘] PERINGATAN: Penggunaan disk root hampir penuh ($disk_usage%)!"
      issues=$((issues + 1))
    else
      echo "[✔] Ruang disk aman ($disk_usage% terpakai)."
    fi

    echo ""
    if [ "$issues" -eq 0 ]; then
      echo "[✔] Hasil: Tidak ditemukan masalah kritis pada sistem Anda."
    else
      echo "[!] Hasil: Ditemukan $issues masalah yang memerlukan perhatian."
    fi
    return
  fi

  if [ -n "$topic" ]; then
    echo "=== BANTUAN SPESIFIK: webforge $topic ==="
    case "$topic" in
      site)
        echo "Kelola situs web / vhost:"
        echo "  webforge site create <domain>      - Membuat vhost dan direktori webroot"
        echo "  webforge site delete <domain>      - Menghapus vhost dan webroot"
        echo "  webforge site list                 - Menampilkan daftar semua situs"
        echo "  webforge site enable|disable <dom> - Mengaktifkan atau menonaktifkan situs"
        ;;
      ssl)
        echo "Kelola Sertifikat SSL/TLS:"
        echo "  webforge ssl issue <domain>        - Menerbitkan SSL Let's Encrypt via acme.sh"
        echo "  webforge ssl renew                 - Memperbarui semua sertifikat SSL"
        echo "  webforge ssl list                  - Daftar sertifikat terdaftar"
        echo "  webforge ssl selfsigned <domain>   - Membuat sertifikat self-signed"
        ;;
      fw)
        echo "Kelola Firewall (nftables):"
        echo "  webforge fw status                 - Menampilkan aturan firewall aktif"
        echo "  webforge fw allow|deny <port>      - Membuka atau menutup port"
        echo "  webforge fw ban|unban <ip>         - Memblokir atau mencabut blokir IP"
        echo "  webforge fw ports                  - Menampilkan daftar port terbuka (ss)"
        ;;
      log|monitoring)
        echo "Analisis Log & Monitoring:"
        echo "  webforge log access [domain]       - Melihat live access log"
        echo "  webforge log error [domain]        - Melihat live error log"
        echo "  webforge log top-ip / top-url      - Statistik IP & URL teratas"
        echo "  webforge monitor / health          - Ringkasan resource & health check"
        ;;
      audit|security)
        echo "Keamanan & Audit Sistem:"
        echo "  webforge audit                     - Memeriksa akun UID 0, firewall, dan status"
        echo "  webforge harden                    - Menerapkan pengamanan file/direktori sensitif"
        echo "  webforge perms <domain>            - Memperbaiki izin file webroot ke www-data"
        echo "  webforge ssh status|port|addkey    - Konfigurasi layanan & akses SSH"
        echo "  webforge user add|remove|list      - Manajemen pengguna admin server"
        ;;
      backup|restore)
        echo "Backup & Pemulihan Data:"
        echo "  webforge backup config|site|all    - Membuat arsip cadangan"
        echo "  webforge backup list               - Menampilkan daftar file backup"
        echo "  webforge restore <file.tar.gz>     - Memulihkan sistem dari arsip backup"
        ;;
      net|system)
        echo "Jaringan & Sistem:"
        echo "  webforge net info|test             - Menampilkan IP/DNS dan tes konektivitas"
        echo "  webforge hostname <nama>           - Mengganti nama host server"
        echo "  webforge sysinfo                   - Informasi kernel, CPU, RAM, dan disk"
        echo "  webforge cleanup                   - Membersihkan log lama dan cache paket"
        ;;
      automation)
        echo "Otomatisasi & Konfigurasi:"
        echo "  webforge timers                    - Daftar systemd timer aktif"
        echo "  webforge setup                     - Wizard interaktif konfigurasi awal"
        echo "  webforge update-check              - Memeriksa pembaruan paket sistem"
        ;;
      *)
        echo "Tidak ada dokumentasi khusus mendalam untuk topik '$topic'. Ketik 'webforge help' untuk daftar utama."
        ;;
    esac
    return
  fi

  # Menu Bantuan Utama
  cat << 'EOF'
==================================================
          WEBFORGE OS - CLI MANAGER
==================================================
Penggunaan: webforge <kategori> [aksi] [parameter]

1. SITUS & VHOST (site)
- webforge site create <domain>      : Buat situs baru
- webforge site delete <domain>      : Hapus situs
- webforge site list                 : Daftar semua situs
- webforge site enable|disable <dom> : Aktifkan/nonaktifkan situs

2. LAYANAN NGINX & KONTROL
- webforge start|stop|restart|reload : Kontrol layanan Nginx
- webforge test                      : Uji sintaks konfigurasi Nginx
- webforge status                    : Status aktif Nginx
- webforge version                   : Versi WebForge OS

3. SSL / TLS (ssl)
- webforge ssl issue <domain>        : Minta sertifikat Let's Encrypt
- webforge ssl renew                 : Perbarui semua sertifikat
- webforge ssl list                  : Daftar sertifikat aktif
- webforge ssl selfsigned <domain>   : Buat sertifikat self-signed

4. FIREWALL (fw)
- webforge fw status                 : Tampilkan aturan aktif
- webforge fw allow|deny <port>      : Buka/tutup port
- webforge fw ban|unban <ip>         : Blokir/cabut IP
- webforge fw ports                  : Daftar port terbuka

5. LOG & MONITORING (log, stats, conn, monitor, disk, health)
- webforge log access|error          : Lihat log live
- webforge log top-ip|top-url        : Analisis statistik akses
- webforge monitor                   : Ringkasan CPU, RAM, & disk
- webforge health                    : Cek cepat kesehatan sistem

6. KEAMANAN (audit, harden, perms, ssh, user)
- webforge audit                     : Audit konfigurasi server
- webforge harden                    : Terapkan pengamanan dasar
- webforge perms <domain>            : Perbaiki izin file webroot
- webforge ssh port <nomor>          : Ganti port SSH
- webforge user add <nama>           : Buat user admin baru

7. BACKUP & RESTORE (backup, restore)
- webforge backup config|site|all    : Buat arsip cadangan
- webforge backup list               : Daftar file backup
- webforge restore <file.tar.gz>     : Pulihkan dari backup

8. JARINGAN & SISTEM (net, hostname, time, sysinfo, cleanup)
- webforge net info|test             : Info jaringan & tes koneksi
- webforge hostname <nama>           : Ganti hostname server
- webforge sysinfo                   : Informasi kernel, CPU, & RAM
- webforge cleanup                   : Bersihkan log lama & cache

9. OTOMATISASI (timers, setup, update-check, export, import)
- webforge timers                    : Daftar systemd timer
- webforge setup                     : Wizard konfigurasi awal
- webforge update-check              : Cek pembaruan paket

10. BANTUAN (help, doctor)
- webforge help                      : Tampilkan menu bantuan ini
- webforge help <perintah>           : Penjelasan perintah spesifik (mis: webforge help audit)
- webforge doctor                    : Diagnosa masalah sistem

EOF
}