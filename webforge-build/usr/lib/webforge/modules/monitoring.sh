#!/usr/bin/env bash

handle_monitoring() {
  local action="$1"
  local sub="$2"
  local param="$3"

  local LOG_DIR="/var/log/nginx"
  local ACCESS_LOG="$LOG_DIR/access.log"
  local ERROR_LOG="$LOG_DIR/error.log"

  # Jika perintah utama adalah 'log'
  if [ "$action" == "log" ]; then
    case "$sub" in
      access)
        if [ -n "$param" ]; then
          ACCESS_LOG="$LOG_DIR/$param.access.log"
        fi
        [ -f "$ACCESS_LOG" ] || ACCESS_LOG="/var/log/httpd/access.log"
        echo "=== Live Access Log ($ACCESS_LOG) ==="
        tail -f "$ACCESS_LOG" 2>/dev/null || echo "Log access tidak ditemukan."
        ;;
      error)
        if [ -n "$param" ]; then
          ERROR_LOG="$LOG_DIR/$param.error.log"
        fi
        [ -f "$ERROR_LOG" ] || ERROR_LOG="/var/log/httpd/error.log"
        echo "=== Live Error Log ($ERROR_LOG) ==="
        tail -f "$ERROR_LOG" 2>/dev/null || echo "Log error tidak ditemukan."
        ;;
      top-ip)
        [ -f "$ACCESS_LOG" ] || ACCESS_LOG="/var/log/nginx/access.log"
        echo "=== 10 IP dengan Request Terbanyak ==="
        awk '{print $1}' "$ACCESS_LOG" 2>/dev/null | sort | uniq -c | sort -nr | head -n 10
        ;;
      top-url)
        [ -f "$ACCESS_LOG" ] || ACCESS_LOG="/var/log/nginx/access.log"
        echo "=== 10 URL Paling Sering Diakses ==="
        awk '{print $7}' "$ACCESS_LOG" 2>/dev/null | sort | uniq -c | sort -nr | head -n 10
        ;;
      status-codes)
        [ -f "$ACCESS_LOG" ] || ACCESS_LOG="/var/log/nginx/access.log"
        echo "=== Rekap Kode Status HTTP ==="
        awk '{print $9}' "$ACCESS_LOG" 2>/dev/null | sort | uniq -c | sort -nr
        ;;
      errors-today)
        local today
        today=$(date '+%d/%b/%Y')
        [ -f "$ERROR_LOG" ] || ERROR_LOG="/var/log/nginx/error.log"
        echo "=== Error Hari Ini ($today) ==="
        grep "$today" "$ERROR_LOG" 2>/dev/null || echo "Tidak ada error tercatat hari ini."
        ;;
      search)
        local keyword="$param"
        [ -z "$keyword" ] && { echo "Gunakan: webforge log search <kata>"; exit 1; }
        echo "=== Hasil Pencarian: '$keyword' ==="
        grep -i "$keyword" "$LOG_DIR"/*.log 2>/dev/null || echo "Tidak ditemukan."
        ;;
      rotate)
        echo "[+] Memaksa rotasi log Nginx..."
        logrotate -f /etc/logrotate.d/nginx 2>/dev/null || systemctl reload nginx
        echo "[+] Rotasi log selesai."
        ;;
      *)
        echo "Sub-perintah log tidak dikenal. Gunakan: access, error, top-ip, top-url, status-codes, errors-today, search, rotate."
        ;;
    es:
    return
  fi

  # Perintah monitoring mandiri lainnya (stats, conn, monitor, disk, health)
  case "$action" in
    stats)
      echo "=== NGINX STUB STATUS ==="
      curl -s http://127.0.0.1/nginx_status 2>/dev/null || echo "Modul stub_status belum dikonfigurasi di Nginx (biasanya di 127.0.0.1/nginx_status)."
      ;;
    conn)
      echo "=== Jumlah Koneksi Aktif (Jaringan) ==="
      ss -s
      ;;
    monitor)
      echo "=== RINGKASAN SUMBER DAYA SISTEM (MONITOR) ==="
      echo "1. Uptime & Load Average:"
      uptime
      echo ""
      echo "2. Penggunaan Memori (RAM & Swap):"
      free -h
      echo ""
      echo "3. Penggunaan Disk Root (/):"
      df -h /
      echo ""
      echo "4. Status Layanan Inti:"
      systemctl is-active --quiet nginx && echo " - Nginx: Aktif" || echo " - Nginx: Mati"
      systemctl is-active --quiet ssh && echo " - SSH: Aktif" || echo " - SSH: Mati"
      ;;
    disk)
      echo "=== Penggunaan Disk per Situs (/var/www) ==="
      if [ -d "/var/www" ]; then
        du -sh /var/www/* 2>/dev/null || echo "Belum ada direktori situs."
      else
        echo "Direktori /var/www tidak ditemukan."
      fi
      ;;
    health)
      echo "=== PEMERIKSAAN KESEHATAN SISTEM (HEALTH CHECK) ==="
      systemctl is-active --quiet nginx && echo "[✔] Nginx: Sehat (Aktif)" || echo "[✘] Nginx: Bermasalah/Mati"
      systemctl is-active --quiet nftables && echo "[✔] Firewall (nftables): Sehat" || echo "[✘] Firewall: Mati"
      systemctl is-active --quiet ssh && echo "[✔] SSH: Sehat" || echo "[✘] SSH: Mati"
      systemctl is-active --quiet systemd-timesyncd && echo "[✔] Waktu (NTP): Sinkron" || echo "[i] Layanan timesyncd tidak aktif."
      ping -c 1 8.8.8.8 > /dev/null 2>&1 && echo "[✔] Koneksi DNS/Internet: Terhubung" || echo "[✘] Koneksi Internet: Terputus"
      [ -d "/var/www" ] && echo "[✔] Direktori Webroot (/var/www): Ada" || echo "[✘] Direktori Webroot hilang"
      ;;
    *)
      echo "Perintah monitoring tidak dikenal. Ketik 'webforge help'."
      ;;
  esac
}