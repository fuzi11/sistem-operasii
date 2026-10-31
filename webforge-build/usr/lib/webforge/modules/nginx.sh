#!/usr/bin/env bash

handle_nginx() {
  local action="$1"
  case "$action" in
    start)
      systemctl start nginx
      echo "[+] Nginx berhasil dijalankan."
      ;;
    stop)
      systemctl stop nginx
      echo "[+] Nginx dihentikan."
      ;;
    restart)
      systemctl restart nginx
      echo "[+] Nginx direstart."
      ;;
    reload)
      if nginx -t; then
        systemctl reload nginx
        echo "[+] Nginx berhasil di-reload."
      else
        echo "[-] Tes konfigurasi Nginx gagal, reload dibatalkan."
      fi
      ;;
    test)
      nginx -t
      ;;
    status)
      systemctl status nginx
      ;;
    enable)
      systemctl enable nginx
      echo "[+] Nginx diaktifkan saat boot."
      ;;
    disable)
      systemctl disable nginx
      echo "[+] Nginx dinonaktifkan saat boot."
      ;;
    version)
      nginx -v
      openssl version
      echo "WebForge OS 1.0 LTS"
      ;;
    modules)
      nginx -V
      ;;
    *)
      echo "Aksi Nginx tidak dikenal."
      ;;
  esac
}