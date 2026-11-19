#!/usr/bin/env bash

handle_nginx() {
  local action="$1"

  case "$action" in
    start)
      systemctl start nginx
      echo "[+] Layanan Nginx berhasil dijalankan."
      ;;
    stop)
      systemctl stop nginx
      echo "[+] Layanan Nginx dihentikan."
      ;;
    restart)
      systemctl restart nginx
      echo "[+] Layanan Nginx direstart penuh."
      ;;
    reload)
      if nginx -t; then
        systemctl reload nginx
        echo "[+] Konfigurasi valid, Nginx berhasil direload tanpa memutus koneksi."
      else
        echo "[-] Tes konfigurasi Nginx gagal, reload dibatalkan."
        exit 1
      fi
      ;;
    test)
      echo "Menjalankan uji sintaks konfigurasi Nginx..."
      nginx -t
      ;;
    status)
      echo "=== STATUS LAYANAN NGINX ==="
      systemctl status nginx --no-pager
      echo ""
      echo "Uptime & Versi Ringkas:"
      nginx -v
      ;;
    enable)
      systemctl enable nginx
      echo "[+] Nginx diaktifkan untuk autostart saat boot."
      ;;
    disable)
      systemctl disable nginx
      echo "[+] Nginx dinonaktifkan dari autostart saat boot."
      ;;
    version)
      echo "=== VERSI SISTEM & LAYANAN ==="
      nginx -v
      openssl version
      echo "WebForge OS 1.0 LTS"
      ;;
    modules)
      echo "=== DAFTAR MODUL NGINX YANG DI-COMPILE ==="
      nginx -V
      ;;
    *)
      echo "Perintah Nginx tidak dikenal. Ketik 'webforge help'."
      ;;
  esac
}
