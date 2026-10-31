#!/usr/bin/env bash

handle_backup() {
  local action="$1"
  local target="$2"
  local arg3="$3"

  local BACKUP_DIR="/var/backups/webforge"
  mkdir -p "$BACKUP_DIR"
  local timestamp
  timestamp=$(date +%Y%m%d_%H%M%S)

  case "$action" in
    config)
      echo "[+] Mem-backup konfigurasi /etc/nginx..."
      local dest="$BACKUP_DIR/nginx_config_$timestamp.tar.gz"
      tar -czf "$dest" -C /etc nginx 2>/dev/null
      echo "[+] Backup config berhasil disimpan di $dest."
      ;;
    site)
      [ -z "$target" ] && { echo "Gunakan: webforge backup site <domain>"; exit 1; }
      echo "[+] Mem-backup webroot situs $target..."
      if [ -d "/var/www/$target" ]; then
        local dest="$BACKUP_DIR/site_${target}_$timestamp.tar.gz"
        tar -czf "$dest" -C /var/www "$target" 2>/dev/null
        echo "[+] Backup situs $target berhasil disimpan di $dest."
      else
        echo "[-] Direktori webroot /var/www/$target tidak ditemukan."
      fi
      ;;
    all)
      echo "[+] Mem-backup seluruh konfigurasi dan situs..."
      local dest="$BACKUP_DIR/webforge_full_$timestamp.tar.gz"
      tar -czf "$dest" -C /etc nginx -C /var www 2>/dev/null
      echo "[+] Backup penuh berhasil disimpan di $dest."
      ;;
    list)
      echo "=== DAFTAR BERKAS BACKUP ($BACKUP_DIR) ==="
      ls -lh "$BACKUP_DIR" 2>/dev/null || echo "Belum ada file backup."
      ;;
    clean)
      local days="${target:-7}"
      echo "[+] Menghapus file backup yang lebih lama dari $days hari..."
      find "$BACKUP_DIR" -type f -name "*.tar.gz" -mtime +"$days" -exec rm -f {} \;
      echo "[+] Pembersihan backup lama selesai."
      ;;
    remote)
      [ -z "$target" ] && { echo "Gunakan: webforge backup remote <user@host>"; exit 1; }
      echo "[+] Mengirim seluruh backup ke server remote $target via rsync..."
      rsync -avz "$BACKUP_DIR/" "$target:$BACKUP_DIR/" 2>/dev/null || echo "[-] Gagal mengirim via rsync. Pastikan SSH key/koneksi aktif."
      echo "[+] Proses pengiriman backup jarak jauh selesai."
      ;;
    restore)
      [ -z "$target" ] && { echo "Gunakan: webforge restore <file_backup.tar.gz>"; exit 1; }
      if [ -f "$target" ]; then
        echo "[+] Memulihkan sistem dari arsip $target..."
        # Ekstrak otomatis ke root /
        tar -xzf "$target" -C / 2>/dev/null
        systemctl reload nginx
        echo "[+] Pemulihan (restore) selesai dan Nginx direload."
      else
        echo "[-] File arsip backup '$target' tidak ditemukan."
      fi
      ;;
    *)
      echo "Perintah Backup/Restore tidak dikenal. Ketik 'webforge help'."
      ;;
  esac
}