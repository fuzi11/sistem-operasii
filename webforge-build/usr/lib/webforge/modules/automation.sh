#!/usr/bin/env bash

handle_automation() {
  local action="$1"
  local sub="$2"
  local param="$3"

  case "$action" in
    timers)
      echo "=== DAFTAR SYSTEMD TIMERS (OTOMATISASI) ==="
      systemctl list-timers --all
      ;;
    timer)
      if [ "$sub" == "enable" ]; then
        [ -z "$param" ] && { echo "Gunakan: webforge timer enable <nama_timer>"; exit 1; }
        echo "[+] Mengaktifkan systemd timer: $param..."
        systemctl enable --now "$param.timer" 2>/dev/null || systemctl enable --now "$param"
        echo "[+] Timer berhasil diaktifkan."
      else
        echo "Gunakan: webforge timer enable <nama>"
      fi
      ;;
    firstboot)
      echo "[+] Menjalankan ulang setup awal sistem (regenerate machine-id & ssh keys)..."
      rm -f /etc/machine-id
      systemd-machine-id-setup
      rm -f /etc/ssh/ssh_host_*
      dpkg-reconfigure openssh-server 2>/dev/null || ssh-keygen -A
      echo "[+] Setup firstboot selesai. Disarankan untuk mereset server."
      ;;
    setup)
      echo "=== WIZARD KONFIGURASI AWAL WEBFORGE OS ==="
      read -rp "Masukkan Hostname baru: " new_host
      [ -n "$new_host" ] && hostnamectl set-hostname "$new_host"

      read -rp "Masukkan username admin baru: " new_admin
      if [ -n "$new_admin" ]; then
        useradd -m -s /bin/bash "$new_admin" 2>/dev/null || echo "User sudah ada."
        passwd "$new_admin"
        usermod -aG wheel,sudo "$new_admin" 2>/dev/null || true
      fi

      read -rp "Masukkan domain situs pertama (kosongkan jika lewati): " first_domain
      if [ -n "$first_domain" ]; then
        mkdir -p "/var/www/$first_domain"
        echo "<h1>Selamat datang di $first_domain (WebForge OS)</h1>" > "/var/www/$first_domain/index.html"
        chown -R www-data:www-data "/var/www/$first_domain"
        echo "[+] Situs pertama $first_domain berhasil disiapkan."
      fi
      echo "[+] Wizard konfigurasi awal selesai!"
      ;;
    update-check)
      echo "=== MEMERIKSA PEMBARUAN PAKET SISTEM ==="
      apt-get update -qq
      apt-get -s upgrade | grep -i "upgraded"
      echo "[+] Pemeriksaan selesai."
      ;;
    export)
      local dest="/var/backups/webforge/webforge_export_$(date +%Y%m%d_%H%M%S).tar.gz"
      mkdir -p /var/backups/webforge
      echo "[+] Mengekspor seluruh konfigurasi (/etc/nginx, dll) ke $dest..."
      tar -czf "$dest" -C /etc nginx 2>/dev/null
      echo "[+] Ekspor selesai. File disimpan di: $dest"
      ;;
    import)
      [ -z "$sub" ] && { echo "Gunakan: webforge import <file_arsip.tar.gz>"; exit 1; }
      if [ -f "$sub" ]; then
        echo "[+] Mengimpor konfigurasi dari arsip $sub..."
        tar -xzf "$sub" -C /etc 2>/dev/null
        systemctl reload nginx
        echo "[+] Impor konfigurasi selesai dan Nginx direload."
      else
        echo "[-] Arsip file '$sub' tidak ditemukan."
      fi
      ;;
    *)
      echo "Perintah Otomatisasi tidak dikenal. Ketik 'webforge help'."
      ;;
  esac
}